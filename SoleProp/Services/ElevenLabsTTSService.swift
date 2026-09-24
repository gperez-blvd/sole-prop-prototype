import Foundation

enum ElevenLabsError: LocalizedError {
    case notConfigured
    case requestFailed(String)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "ElevenLabs API key isn't set (ELEVENLABS_API_KEY environment variable)."
        case .requestFailed(let message):
            return "ElevenLabs request failed: \(message)"
        }
    }
}

/// Text-to-speech via ElevenLabs' REST API, using the fixed voice ID from
/// `ElevenLabsConfig`. Throws `ElevenLabsError.notConfigured` until a
/// teammate sets `ELEVENLABS_API_KEY` on their scheme.
struct ElevenLabsTTSService {
    func synthesize(text: String) async throws -> Data {
        guard let apiKey = ElevenLabsConfig.apiKey, !apiKey.isEmpty else {
            throw ElevenLabsError.notConfigured
        }

        let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/\(ElevenLabsConfig.voiceID)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("audio/mpeg", forHTTPHeaderField: "Accept")
        request.httpBody = try JSONSerialization.data(withJSONObject: [
            "text": text,
            "model_id": "eleven_turbo_v2_5",
        ])

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw ElevenLabsError.requestFailed("HTTP \(status)")
        }
        return data
    }
}
