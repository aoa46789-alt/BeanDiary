import Foundation

enum YouTubeError: LocalizedError {
    case notConfigured
    case invalidResponse
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "YouTube API 키가 설정되지 않았습니다. 더보기 → 설정에서 API 키를 입력하세요."
        case .invalidResponse:
            return "YouTube 응답을 해석하지 못했습니다."
        case .apiError(let message):
            return message
        }
    }
}

actor YouTubeService {
    static let shared = YouTubeService()

    private let session: URLSession
    private let decoder = JSONDecoder()

    init(session: URLSession = .shared) {
        self.session = session
    }

    func searchVideos(query: String, maxResults: Int = 10) async throws -> [YouTubeVideo] {
        guard let apiKey = YouTubeConfiguration.apiKey else {
            throw YouTubeError.notConfigured
        }

        var components = URLComponents(string: "https://www.googleapis.com/youtube/v3/search")!
        components.queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "type", value: "video"),
            URLQueryItem(name: "relevanceLanguage", value: "ko"),
            URLQueryItem(name: "maxResults", value: String(maxResults)),
            URLQueryItem(name: "key", value: apiKey)
        ]

        let (data, response) = try await session.data(from: components.url!)
        try validateHTTP(response: response, data: data)

        let searchResponse = try decoder.decode(YouTubeSearchResponse.self, from: data)
        return searchResponse.items.compactMap { item in
            guard let videoId = item.id.videoId else { return nil }
            let thumb = item.snippet.thumbnails?.medium?.url ?? item.snippet.thumbnails?.defaultThumb?.url
            return YouTubeVideo(
                videoId: videoId,
                title: item.snippet.title,
                channelTitle: item.snippet.channelTitle,
                thumbnailURL: thumb.flatMap(URL.init(string:)),
                publishedAt: item.snippet.publishedAt
            )
        }
    }

    func fetchVideoDescription(videoId: String) async throws -> String {
        guard let apiKey = YouTubeConfiguration.apiKey else {
            throw YouTubeError.notConfigured
        }

        var components = URLComponents(string: "https://www.googleapis.com/youtube/v3/videos")!
        components.queryItems = [
            URLQueryItem(name: "part", value: "snippet"),
            URLQueryItem(name: "id", value: videoId),
            URLQueryItem(name: "key", value: apiKey)
        ]

        let (data, response) = try await session.data(from: components.url!)
        try validateHTTP(response: response, data: data)

        let videoResponse = try decoder.decode(YouTubeVideosResponse.self, from: data)
        guard let description = videoResponse.items.first?.snippet.description else {
            throw YouTubeError.invalidResponse
        }
        return description
    }

    private func validateHTTP(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200...299).contains(http.statusCode) else {
            struct ErrorBody: Decodable {
                struct Detail: Decodable { let message: String? }
                let error: Detail?
            }
            let message = (try? decoder.decode(ErrorBody.self, from: data))?.error?.message ?? "HTTP \(http.statusCode)"
            throw YouTubeError.apiError(message)
        }
    }
}

private struct YouTubeSearchResponse: Decodable {
    let items: [SearchItem]
}

private struct SearchItem: Decodable {
    let id: VideoID
    let snippet: Snippet
}

private struct VideoID: Decodable {
    let videoId: String?
}

private struct YouTubeVideosResponse: Decodable {
    let items: [VideoItem]
}

private struct VideoItem: Decodable {
    let snippet: VideoSnippet
}

private struct VideoSnippet: Decodable {
    let description: String
}

private struct Snippet: Decodable {
    let title: String
    let channelTitle: String
    let publishedAt: String?
    let thumbnails: Thumbnails?
}

private struct Thumbnails: Decodable {
    let medium: Thumb?
    let defaultThumb: Thumb?

    enum CodingKeys: String, CodingKey {
        case medium
        case defaultThumb = "default"
    }
}

private struct Thumb: Decodable {
    let url: String
}

#if DEBUG
extension YouTubeVideo {
    static let preview = YouTubeVideo(
        videoId: "abc123",
        title: "에티오피아 예가체프 V60 핸드드립 레시피",
        channelTitle: "Coffee Lab",
        thumbnailURL: nil,
        publishedAt: nil
    )
}
#endif
