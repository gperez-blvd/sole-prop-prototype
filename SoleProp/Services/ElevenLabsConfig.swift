import Foundation

/// ElevenLabs credentials. The API key is never committed — it's read from an
/// environment variable set on the Xcode scheme (Product > Scheme > Edit
/// Scheme > Run > Arguments > Environment Variables), so this compiles and
/// runs for every teammate with `isConfigured == false` until they set it.
enum ElevenLabsConfig {
    static let voiceID = "kvC9CRs6pCalJVozY8A1"

    static var apiKey: String? {
        ProcessInfo.processInfo.environment["ELEVENLABS_API_KEY"]
    }

    static var isConfigured: Bool {
        apiKey?.isEmpty == false
    }
}
