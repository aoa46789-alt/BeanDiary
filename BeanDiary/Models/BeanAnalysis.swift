import Foundation

struct BeanAnalysis: Codable, Equatable {
    let flavorNotes: [String]
    let acidity: Int
    let body: Int
    let sweetness: Int
    let description: String
    let recommendedBrewMethod: String
    let isEstimated: Bool
    let recipe: SuggestedRecipe?

    struct SuggestedRecipe: Codable, Equatable {
        let grindSize: String?
        let waterTemp: Int?
        let ratio: String?
        let totalBrewTimeSec: Int?
        let steps: [BrewStep]?
    }

    static func decode(from json: String) -> BeanAnalysis? {
        guard let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(BeanAnalysis.self, from: data)
    }

    static func encode(_ analysis: BeanAnalysis) -> String? {
        guard let data = try? JSONEncoder().encode(analysis) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

extension CoffeeBean {
    var beanAnalysis: BeanAnalysis? {
        guard let analysisJSON else { return nil }
        return BeanAnalysis.decode(from: analysisJSON)
    }

    func storeAnalysis(_ analysis: BeanAnalysis) {
        analysisJSON = BeanAnalysis.encode(analysis)
        analysisFetchedAt = .now
    }
}
