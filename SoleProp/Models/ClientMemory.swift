import Foundation

/// What DETAIL knows about one client — the Swift mirror of
/// `RelationalStore.clientMemory()` in detail-poc. Visits are the evidence;
/// `cadenceBelief` is the PATTERN that says DETAIL is confident enough to
/// say so. The day count is derived from the visits, never stored, so the
/// two can't disagree.
///
/// Commercial only. The clinical side (`ClientChart`) is reached from the
/// client page as a link and is never read aloud — `sentence` is built from
/// visits alone and can't include anything from it.
struct ClientMemory: Identifiable, Hashable {
    let id = UUID()
    let fullName: String
    let clientSince: Date
    /// Completed visits, newest first. Today's appointment isn't one yet.
    let visits: [ClientVisit]
    /// `nil` until DETAIL has noticed a rebooking rhythm, and again after she
    /// says it isn't true.
    var cadenceBelief: CadenceBelief?
    let chart: ClientChart

    var firstName: String {
        fullName.split(separator: " ").first.map(String.init) ?? fullName
    }

    /// Median gap between visits, in days. Needs a belief and at least two
    /// gaps to compare — one gap is a coincidence, not a rhythm.
    var cadenceDays: Int? {
        guard cadenceBelief != nil, visits.count >= 3 else { return nil }
        let gaps = zip(visits, visits.dropFirst())
            .map { Calendar.current.dateComponents([.day], from: $1.date, to: $0.date).day ?? 0 }
            .sorted()
        return gaps[gaps.count / 2]
    }

    var gapsObserved: Int { max(visits.count - 1, 0) }

    /// The most recent visit for each service, newest first.
    var lastOfEach: [(service: String, date: Date)] {
        var seen: [(service: String, date: Date)] = []
        for visit in visits where !seen.contains(where: { $0.service == visit.service }) {
            seen.append((visit.service, visit.date))
        }
        return seen
    }

    var productsBought: [(name: String, dates: [Date])] {
        var byName: [String: [Date]] = [:]
        for visit in visits {
            for product in visit.productsBought { byName[product, default: []].append(visit.date) }
        }
        return byName
            .map { (name: $0.key, dates: $0.value.sorted(by: >)) }
            .sorted { ($0.dates.first ?? .distantPast) > ($1.dates.first ?? .distantPast) }
    }

    /// The one line DETAIL may say out loud about her. `nil` means there's
    /// nothing worth saying yet — which, for a new client, is the calm case.
    var sentence: String? {
        guard let days = cadenceDays else { return nil }
        return "\(firstName) rebooks about every \(Self.weeksPhrase(days))."
    }

    static func weeksPhrase(_ days: Int) -> String {
        let weeks = Int((Double(days) / 7).rounded())
        let words = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve"]
        return "\(weeks < words.count ? words[weeks] : String(weeks)) weeks"
    }
}

struct ClientVisit: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let service: String
    var productsBought: [String] = []
}

/// PATTERN with the `cadence` unit — the belief, not the number.
struct CadenceBelief: Hashable {
    let noticedOn: Date
    let confidence: Threshold.Confidence
    /// She confirmed it, rather than DETAIL only having mentioned it once.
    let confirmedByHer: Bool
}

/// CHART — the clinical record. On screen only, after she chooses to open it.
struct ClientChart: Hashable {
    var skinType: String?
    var allergies: String
    var medications: String
    var contraindications: String
    /// Her most recent treatment note, if there is one.
    var lastNote: ChartNote?
}

struct ChartNote: Hashable {
    let date: Date
    let service: String
    let text: String
}
