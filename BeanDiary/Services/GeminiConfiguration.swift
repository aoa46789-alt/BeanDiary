import Foundation

enum GeminiConfiguration {
    static let apiKeyUserDefaultsKey = "geminiApiKey"
    static let defaultModel = "gemini-2.0-flash"

    static var apiKey: String? {
        if let stored = UserDefaults.standard.string(forKey: apiKeyUserDefaultsKey),
           !stored.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return stored.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let env = ProcessInfo.processInfo.environment["GEMINI_API_KEY"],
           !env.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return env.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return nil
    }

    static var isConfigured: Bool { apiKey != nil }
}
