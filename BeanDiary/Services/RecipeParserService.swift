import Foundation
import SwiftData

struct ParsedRecipeDraft: Codable, Equatable {
    let coffeeGrams: Double
    let waterGrams: Double?
    let ratio: String?
    let waterTemp: Int?
    let dripper: String?
    let brewMethod: String?
    let totalBrewTimeSec: Int?
    let sourceGrinder: String?
    let sourceGrindSetting: String?
    let steps: [BrewStep]
    let isEstimated: Bool

    func toParsedRecipe(beanName: String, sourceType: String, videoId: String?, userGrinder: String) -> ParsedRecipe {
        let conversion = GrindConverterService.applyGrindConversion(
            sourceGrinder: sourceGrinder,
            sourceGrindSetting: sourceGrindSetting,
            targetGrinder: userGrinder
        )
        let stepsJSON = (try? String(data: JSONEncoder().encode(steps), encoding: .utf8)) ?? "[]"

        return ParsedRecipe(
            beanName: beanName,
            sourceType: sourceType,
            sourceVideoId: videoId,
            coffeeGrams: coffeeGrams,
            waterGrams: waterGrams,
            ratio: ratio,
            waterTemp: waterTemp,
            dripper: dripper,
            brewMethod: brewMethod,
            totalBrewTimeSec: totalBrewTimeSec,
            sourceGrinder: sourceGrinder,
            sourceGrindSetting: sourceGrindSetting,
            convertedGrinder: userGrinder,
            convertedGrindClicks: conversion.clicks,
            grindConversionNote: conversion.note,
            stepsJSON: stepsJSON
        )
    }
}

extension ParsedRecipe {
    var brewSteps: [BrewStep] {
        get {
            guard let data = stepsJSON.data(using: .utf8),
                  let steps = try? JSONDecoder().decode([BrewStep].self, from: data) else {
                return []
            }
            return steps
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let json = String(data: data, encoding: .utf8) {
                stepsJSON = json
            }
        }
    }

    static func findCached(beanName: String, videoId: String, in context: ModelContext) -> ParsedRecipe? {
        let descriptor = FetchDescriptor<ParsedRecipe>()
        return (try? context.fetch(descriptor))?.first {
            $0.beanName == beanName && $0.sourceVideoId == videoId
        }
    }
}

enum RecipeParserService {
    static func parseRecipe(
        beanName: String,
        sourceText: String,
        videoTitle: String? = nil
    ) async throws -> ParsedRecipeDraft {
        guard GeminiConfiguration.isConfigured else {
            throw GeminiError.notConfigured
        }

        let prompt = buildPrompt(beanName: beanName, sourceText: sourceText, videoTitle: videoTitle)
        let jsonText = try await requestJSON(prompt: prompt)
        guard let data = jsonText.data(using: .utf8),
              let draft = try? JSONDecoder().decode(ParsedRecipeDraft.self, from: data) else {
            throw GeminiError.decodingFailed
        }
        return draft
    }

    private static func buildPrompt(beanName: String, sourceText: String, videoTitle: String?) -> String {
        var lines = [
            "당신은 핸드드립 레시피 분석 전문가입니다. 아래 텍스트에서 추출 파라미터를 JSON으로 구조화하세요.",
            "정보가 없으면 합리적으로 추정하고 isEstimated를 true로 설정하세요.",
            "원두: \(beanName)"
        ]
        if let videoTitle, !videoTitle.isEmpty {
            lines.append("영상 제목: \(videoTitle)")
        }
        lines += [
            "",
            "레시피 원문:",
            sourceText.prefix(8000).description,
            "",
            "JSON 스키마 (마크다운 없이):",
            """
            {
              "coffeeGrams": 15,
              "waterGrams": 225,
              "ratio": "1:15",
              "waterTemp": 93,
              "dripper": "V60 02",
              "brewMethod": "핸드드립",
              "totalBrewTimeSec": 150,
              "sourceGrinder": "EK43",
              "sourceGrindSetting": "2.5",
              "isEstimated": false,
              "steps": [
                { "order": 1, "label": "뜸들이기", "waterAmount": 30, "durationSec": 30, "instruction": "설명" }
              ]
            }
            """
        ]
        return lines.joined(separator: "\n")
    }

    private static func requestJSON(prompt: String) async throws -> String {
        guard let apiKey = GeminiConfiguration.apiKey else {
            throw GeminiError.notConfigured
        }

        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(GeminiConfiguration.defaultModel):generateContent?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = GeminiJSONRequest(prompt: prompt)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw GeminiError.apiError("HTTP \(http.statusCode)")
        }

        let geminiResponse = try JSONDecoder().decode(GeminiJSONResponse.self, from: data)
        guard let text = geminiResponse.candidates?.first?.content?.parts?.first?.text else {
            throw GeminiError.invalidResponse
        }
        return cleanJSONText(text)
    }

    private static func cleanJSONText(_ text: String) -> String {
        var result = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if result.hasPrefix("```json") { result = result.replacingOccurrences(of: "```json", with: "") }
        if result.hasPrefix("```") { result = result.replacingOccurrences(of: "```", with: "") }
        if result.hasSuffix("```") { result = String(result.dropLast(3)) }
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private struct GeminiJSONRequest: Encodable {
    let contents: [Content]
    let generationConfig: GenerationConfig

    init(prompt: String) {
        contents = [Content(parts: [Part(text: prompt)])]
        generationConfig = GenerationConfig(responseMimeType: "application/json")
    }

    struct Content: Encodable {
        let parts: [Part]
    }

    struct Part: Encodable {
        let text: String
    }

    struct GenerationConfig: Encodable {
        let responseMimeType: String
    }
}

private struct GeminiJSONResponse: Decodable {
    let candidates: [Candidate]?

    struct Candidate: Decodable {
        let content: Content?
    }

    struct Content: Decodable {
        let parts: [Part]?
    }

    struct Part: Decodable {
        let text: String?
    }
}

#if DEBUG
extension ParsedRecipeDraft {
    static let preview = ParsedRecipeDraft(
        coffeeGrams: 15,
        waterGrams: 225,
        ratio: "1:15",
        waterTemp: 93,
        dripper: "V60 02",
        brewMethod: "핸드드립",
        totalBrewTimeSec: 150,
        sourceGrinder: "EK43",
        sourceGrindSetting: "2.5",
        steps: [
            BrewStep(order: 1, label: "뜸들이기", waterAmount: 30, durationSec: 30, instruction: "중심에 부드럽게"),
            BrewStep(order: 2, label: "1차 주수", waterAmount: 100, durationSec: 45, instruction: "나선형으로")
        ],
        isEstimated: false
    )
}
#endif
