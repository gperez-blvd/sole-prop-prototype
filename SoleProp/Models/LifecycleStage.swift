import Foundation

/// `BUSINESS.△ Lifecycle Stage` — observed, never consulted for layout. Every
/// screen renders from the same components at every stage; only the density
/// of the seed data (see `HomeMockData`) changes. Exposed here only for the
/// PROTOTYPE control in `MenuSheet` and its readout — this is demo scaffolding,
/// not a real product concept Jazz ever sees.
enum LifecycleStage: String, CaseIterable, Identifiable {
    case activating
    case steady
    case established

    var id: String { rawValue }

    var stageName: String {
        switch self {
        case .activating: "ACTIVATING"
        case .steady: "STEADY"
        case .established: "ESTABLISHED"
        }
    }

    var deckPhrase: String {
        switch self {
        case .activating: "We learn you"
        case .steady: "We know you"
        case .established: "We grow you"
        }
    }

    var signalsPerDay: Int {
        switch self {
        case .activating: 40
        case .steady: 412
        case .established: 500
        }
    }

    var cuesSpoken: Int {
        switch self {
        case .activating: 3
        case .steady: 5
        case .established: 5
        }
    }

    var thresholdCount: Int {
        switch self {
        case .activating: 4
        case .steady: 12
        case .established: 20
        }
    }

    var knowledgeLevel: Int {
        switch self {
        case .activating: 32
        case .steady: 82
        case .established: 92
        }
    }
}
