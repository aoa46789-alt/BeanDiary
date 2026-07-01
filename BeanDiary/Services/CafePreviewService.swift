import Foundation

enum CafePreviewService {
    static func fetchPreview(for spot: CafeSpot) async throws -> CafePreview {
        guard GeminiConfiguration.isConfigured else {
            throw GeminiError.notConfigured
        }

        let prompt = """
        당신은 스페셜티 커피 카페 리뷰어입니다. 아래 카페에 대해 방문 전 미리보기 요약을 한국어 JSON으로 작성하세요.
        정보가 부족하면 합리적으로 추정하고 reviewSentiment에 "추정"을 포함하세요.

        카페명: \(spot.name)
        주소: \(spot.address ?? "미상")
        콜럼버스 가이드: \(spot.isColumbusGuide ? "예" : "아니오")
        드립 전문: \(spot.isDripSpecialty == true ? "예" : "미상")

        JSON 스키마 (마크다운 없이):
        {
          "highlights": ["특징1", "특징2"],
          "characteristics": "분위기·공간 한 줄",
          "tasteSummary": "커피 맛 요약 2문장",
          "reviewSentiment": "긍정/중립/부정 또는 추정",
          "reviewSummary": "리뷰 요약 2~3문장",
          "recommendedMenu": "추천 메뉴 또는 null",
          "dripSpecialtyNote": "드립 전문점이면 특징, 아니면 null",
          "columbusNote": "콜럼버스 선정이면 특징, 아니면 null",
          "isDripSpecialty": true/false/null
        }
        """

        let jsonText = try await GeminiJSONClient.requestJSON(prompt: prompt)
        guard let data = jsonText.data(using: .utf8),
              let preview = try? JSONDecoder().decode(CafePreview.self, from: data) else {
            throw GeminiError.decodingFailed
        }
        return preview
    }
}

enum GeminiJSONClient {
    static func requestJSON(prompt: String) async throws -> String {
        guard let apiKey = GeminiConfiguration.apiKey else {
            throw GeminiError.notConfigured
        }

        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(GeminiConfiguration.defaultModel):generateContent?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(GeminiJSONBody(prompt: prompt))

        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw GeminiError.apiError("HTTP \(http.statusCode)")
        }

        let geminiResponse = try JSONDecoder().decode(GeminiJSONBodyResponse.self, from: data)
        guard let text = geminiResponse.candidates?.first?.content?.parts?.first?.text else {
            throw GeminiError.invalidResponse
        }
        return cleanJSON(text)
    }

    private static func cleanJSON(_ text: String) -> String {
        var result = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if result.hasPrefix("```json") { result = result.replacingOccurrences(of: "```json", with: "") }
        if result.hasPrefix("```") { result = result.replacingOccurrences(of: "```", with: "") }
        if result.hasSuffix("```") { result = String(result.dropLast(3)) }
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private struct GeminiJSONBody: Encodable {
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

private struct GeminiJSONBodyResponse: Decodable {
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
