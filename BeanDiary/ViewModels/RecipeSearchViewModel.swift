import Foundation
import SwiftData

@MainActor
@Observable
final class RecipeSearchViewModel {
    let bean: CoffeeBean
    let recommendedBrewMethod: String?

    var videos: [YouTubeVideo] = []
    var selectedRecipe: ParsedRecipe?
    var isSearching = false
    var isParsing = false
    var parsingVideoId: String?
    var errorMessage: String?
    var playerVideo: YouTubeVideo?

    init(bean: CoffeeBean, recommendedBrewMethod: String? = nil) {
        self.bean = bean
        self.recommendedBrewMethod = recommendedBrewMethod
    }

    var searchQuery: String {
        let brew = recommendedBrewMethod ?? "핸드드립"
        return "\(bean.name) \(brew) 레시피"
    }

    func search(context: ModelContext) async {
        guard YouTubeConfiguration.isConfigured else {
            errorMessage = YouTubeError.notConfigured.errorDescription
            return
        }

        isSearching = true
        errorMessage = nil
        defer { isSearching = false }

        do {
            videos = try await YouTubeService.shared.searchVideos(query: searchQuery)
            if videos.isEmpty {
                errorMessage = "검색 결과가 없습니다."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func parseVideo(_ video: YouTubeVideo, context: ModelContext, userGrinder: String) async {
        if let cached = ParsedRecipe.findCached(beanName: bean.name, videoId: video.videoId, in: context) {
            selectedRecipe = cached
            return
        }

        guard GeminiConfiguration.isConfigured else {
            errorMessage = GeminiError.notConfigured.errorDescription
            return
        }

        isParsing = true
        parsingVideoId = video.videoId
        errorMessage = nil
        defer {
            isParsing = false
            parsingVideoId = nil
        }

        do {
            let description = try await YouTubeService.shared.fetchVideoDescription(videoId: video.videoId)
            let combined = "제목: \(video.title)\n\n\(description)"
            let draft = try await RecipeParserService.parseRecipe(
                beanName: bean.name,
                sourceText: combined,
                videoTitle: video.title
            )
            let recipe = draft.toParsedRecipe(
                beanName: bean.name,
                sourceType: "youtube",
                videoId: video.videoId,
                userGrinder: userGrinder
            )
            context.insert(recipe)
            try context.save()
            selectedRecipe = recipe
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
