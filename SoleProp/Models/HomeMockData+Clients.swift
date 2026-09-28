import Foundation

/// Everyone on file, plus what DETAIL knows about each. Mirrors detail-poc:
/// Tasha Ward's history is her seeded one (`seed.ts` → "Tasha's history"):
/// facials and peels about every five weeks, the Vitamin C serum every other
/// visit, tox from her last visit on. Everyone else is generated from a
/// one-line spec below. Dates are relative to today, like the rest of
/// `HomeMockData`, so the pages read right whenever the demo runs.
///
/// Stage-independent on purpose: the lifecycle switch changes what today
/// looks like, not who she's seen.
extension HomeMockData {
    /// Most recently seen first; anyone without a visit yet follows,
    /// alphabetically — same order as `RelationalStore.clientDirectory()`.
    static var clientDirectory: [ClientMemory] {
        let all = [tasha] + clientSpecs.map(memory(from:))
        let seen = all.filter { !$0.visits.isEmpty }.sorted { $0.visits[0].date > $1.visits[0].date }
        let unseen = all.filter(\.visits.isEmpty).sorted { $0.fullName < $1.fullName }
        return seen + unseen
    }

    /// The client behind an appointment, matched on first name and last
    /// initial ("Tasha W." → Tasha Ward). A first-timer is always a first
    /// visit, whatever else is on file.
    static func clientMemory(for appointment: Appointment) -> ClientMemory? {
        let parts = appointment.clientName.split(separator: " ")
        let first = parts.first.map(String.init) ?? appointment.clientName
        let initial = parts.dropFirst().first?.first
        let match = clientDirectory.first { memory in
            let full = memory.fullName.split(separator: " ")
            return full.first.map(String.init) == first && (initial == nil || full.dropFirst().first?.first == initial)
        }
        if appointment.isFirstTime { return firstVisit(named: match?.fullName ?? appointment.clientName) }
        return match
    }

    private static func daysAgo(_ days: Int) -> Date {
        let calendar = Calendar.current
        let afternoon = calendar.date(bySettingHour: 13, minute: 30, second: 0, of: Date()) ?? Date()
        return calendar.date(byAdding: .day, value: -days, to: afternoon) ?? afternoon
    }

    private static let serum = "Vitamin C serum"

    private static var tasha: ClientMemory {
        ClientMemory(
            fullName: "Tasha Ward",
            clientSince: daysAgo(281),
            visits: [
                ClientVisit(date: daysAgo(36), service: "Neurotoxin", productsBought: [serum]),
                ClientVisit(date: daysAgo(71), service: "Chemical peel"),
                ClientVisit(date: daysAgo(106), service: "HydraFacial", productsBought: [serum]),
                ClientVisit(date: daysAgo(141), service: "HydraFacial"),
                ClientVisit(date: daysAgo(176), service: "Chemical peel", productsBought: [serum]),
                ClientVisit(date: daysAgo(211), service: "HydraFacial"),
                ClientVisit(date: daysAgo(246), service: "Chemical peel", productsBought: [serum]),
                ClientVisit(date: daysAgo(281), service: "HydraFacial"),
            ],
            // Her third visit — the first point there were two gaps to compare.
            cadenceBelief: CadenceBelief(noticedOn: daysAgo(211), confidence: .high, confirmedByHer: true),
            chart: ClientChart(
                skinType: "Fitzpatrick IV · combination, reacts to strong acids",
                allergies: "None known",
                medications: "None reported",
                contraindications: "None",
                lastNote: ChartNote(
                    date: daysAgo(71),
                    service: "Chemical peel",
                    text: "Medium-depth peel, 20% TCA, one pass. Flaking and redness through day 3. Go lighter next time."
                )
            )
        )
    }

    private static func firstVisit(named name: String) -> ClientMemory {
        ClientMemory(
            fullName: name,
            clientSince: Calendar.current.startOfDay(for: Date()),
            visits: [],
            cadenceBelief: nil,
            chart: plainChart
        )
    }

    private static let plainChart = ClientChart(
        skinType: nil,
        allergies: "None known",
        medications: "None reported",
        contraindications: "None",
        lastNote: nil
    )

    /// One client as a rhythm: `visits` visits, `cadence` days apart, the
    /// latest `lastDaysAgo` days back, cycling through `services`.
    /// `serumEvery` buys the serum on every nth visit.
    private struct ClientSpec {
        let name: String
        let services: [String]
        let visits: Int
        let lastDaysAgo: Int
        var cadence: Int = 0
        var serumEvery: Int?
    }

    /// DETAIL only claims a rhythm once there are four visits behind it —
    /// it noticed at the third and has had one more to check against.
    private static func memory(from spec: ClientSpec) -> ClientMemory {
        let visits = (0..<spec.visits).map { k in
            ClientVisit(
                date: daysAgo(spec.lastDaysAgo + k * spec.cadence),
                service: spec.services[k % spec.services.count],
                productsBought: spec.serumEvery.map { k % $0 == 0 ? [serum] : [] } ?? []
            )
        }
        let belief = spec.visits >= 4
            ? CadenceBelief(noticedOn: visits[spec.visits - 3].date, confidence: spec.visits >= 6 ? .high : .medium, confirmedByHer: spec.visits >= 6)
            : nil
        return ClientMemory(
            fullName: spec.name,
            clientSince: visits.last?.date ?? Calendar.current.startOfDay(for: Date()),
            visits: visits,
            cadenceBelief: belief,
            chart: plainChart
        )
    }

    private static let clientSpecs: [ClientSpec] = [
        ClientSpec(name: "Maya Nguyen", services: [], visits: 0, lastDaysAgo: 0),
        ClientSpec(name: "Priya Sharma", services: ["Lip filler"], visits: 4, lastDaysAgo: 80, cadence: 84),
        ClientSpec(name: "Dani Reyes", services: ["Neurotoxin"], visits: 6, lastDaysAgo: 88, cadence: 84),
        ClientSpec(name: "Reese Okafor", services: ["Lip filler"], visits: 3, lastDaysAgo: 150, cadence: 180),
        ClientSpec(name: "Corey Lowe", services: ["HydraFacial"], visits: 7, lastDaysAgo: 40, cadence: 42, serumEvery: 3),
        ClientSpec(name: "Lena Kim", services: ["HydraFacial"], visits: 14, lastDaysAgo: 21, cadence: 28, serumEvery: 3),
        ClientSpec(name: "Morgan Blake", services: ["HydraFacial"], visits: 3, lastDaysAgo: 12, cadence: 60),
        ClientSpec(name: "Ava James", services: ["Chemical peel"], visits: 2, lastDaysAgo: 19, cadence: 45),
        ClientSpec(name: "Renee Cole", services: ["Neurotoxin", "Lip filler"], visits: 20, lastDaysAgo: 30, cadence: 42),
        ClientSpec(name: "Kiara Martinez", services: ["Neurotoxin"], visits: 1, lastDaysAgo: 200),
        ClientSpec(name: "Jess Turner", services: ["HydraFacial", "Chemical peel"], visits: 5, lastDaysAgo: 60, cadence: 35, serumEvery: 2),
        ClientSpec(name: "Nina Patel", services: ["Laser resurfacing"], visits: 3, lastDaysAgo: 33, cadence: 30),
        ClientSpec(name: "Sofia Diaz", services: ["Neurotoxin"], visits: 8, lastDaysAgo: 7, cadence: 91),
        ClientSpec(name: "Bree Foster", services: ["Chemical peel"], visits: 2, lastDaysAgo: 300, cadence: 60),
        ClientSpec(name: "Chloe Grant", services: ["Lip filler"], visits: 1, lastDaysAgo: 14),
        ClientSpec(name: "Alyssa Hayes", services: ["HydraFacial"], visits: 4, lastDaysAgo: 45, cadence: 30),
        ClientSpec(name: "Camille Ibarra", services: ["Neurotoxin"], visits: 5, lastDaysAgo: 110, cadence: 98),
        ClientSpec(name: "Jade Keller", services: ["Laser resurfacing"], visits: 2, lastDaysAgo: 70, cadence: 30),
        ClientSpec(name: "Harper Jansen", services: ["HydraFacial"], visits: 6, lastDaysAgo: 3, cadence: 35, serumEvery: 2),
    ]
}
