import Foundation

struct ConversationMessage: Identifiable {
    enum Role {
        case user
        case assistant
        case system
    }

    let id = UUID()
    let role: Role
    let text: String
}
