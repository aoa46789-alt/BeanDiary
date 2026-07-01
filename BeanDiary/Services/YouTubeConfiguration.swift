import Foundation

struct YouTubeVideo: Identifiable, Equatable, Hashable, Codable {
    let videoId: String
    let title: String
    let channelTitle: String
    let thumbnailURL: URL?
    let publishedAt: String?

    var id: String { videoId }
}

enum YouTubeConfiguration {
    static let apiKeyUserDefaultsKey = "youtubeApiKey"

    static var apiKey: String? {
        if let stored = UserDefaults.standard.string(forKey: apiKeyUserDefaultsKey),
           !stored.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return stored.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let env = ProcessInfo.processInfo.environment["YOUTUBE_API_KEY"],
           !env.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return env.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        // Google Cloud에서 동일 키로 YouTube API를 활성화한 경우 Gemini 키 재사용
        return GeminiConfiguration.apiKey
    }

    static var isConfigured: Bool { apiKey != nil }
}
