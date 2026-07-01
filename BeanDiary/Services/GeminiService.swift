import Foundation

enum GeminiError: LocalizedError {
    case notConfigured
    case invalidResponse
    case apiError(String)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Gemini API 키가 설정되지 않았습니다. 더보기 → 설정에서 API 키를 입력하세요."
        case .invalidResponse:
            return "Gemini 응답을 해석하지 못했습니다."
        case .apiError(let message):
            return message
        case .decodingFailed:
            return "AI 분석 결과 JSON 파싱에 실패했습니다."
        }
    }
}

actor GeminiService {
    static let shared = GeminiService()

    private let session: URLSession
    private let decoder = JSONDecoder()

    init(session: URLSession = .shared) {
        self.session = session
    }

    func analyzeBean(
        name: String,
        roaster: String?,
        origin: String?,
        roastLevel: String?
    ) async throws -> BeanAnalysis {
        guard let apiKey = GeminiConfiguration.apiKey else {
            throw GeminiError.notConfigured
        }

        let prompt = buildPrompt(
            name: name,
            roaster: roaster,
            origin: origin,
            roastLevel: roastLevel
        )

        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(GeminiConfiguration.defaultModel):generateContent?key=\(apiKey)")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(GeminiGenerateRequest(prompt: prompt))

        let (data, response) = try await session.data(for: request)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            let message = parseAPIError(from: data) ?? "HTTP \(http.statusCode)"
            throw GeminiError.apiError(message)
        }

        let geminiResponse = try decoder.decode(GeminiGenerateResponse.self, from: data)
        guard let text = geminiResponse.candidates?.first?.content?.parts?.first?.text else {
            throw GeminiError.invalidResponse
        }

        let cleaned = cleanJSONText(text)
        guard let jsonData = cleaned.data(using: .utf8),
              let analysis = try? decoder.decode(BeanAnalysis.self, from: jsonData) else {
            throw GeminiError.decodingFailed
        }

        return analysis
    }

    private func buildPrompt(
        name: String,
        roaster: String?,
        origin: String?,
        roastLevel: String?
    ) -> String {
        var lines = [
            "당신은 스페셜티 커피 전문가입니다. 아래 원두 정보를 바탕으로 한국어로 분석하세요.",
            "정보가 부족하면 합리적으로 추정하고 isEstimated를 true로 설정하세요.",
            "",
            "원두 이름: \(name)"
        ]
        if let roaster, !roaster.isEmpty { lines.append("로스터리: \(roaster)") }
        if let origin, !origin.isEmpty { lines.append("산지: \(origin)") }
        if let roastLevel, !roastLevel.isEmpty { lines.append("로스팅: \(roastLevel)") }

        lines += [
            "",
            "다음 JSON 스키마로만 응답하세요 (마크다운 없이):",
            """
            {
              "flavorNotes": ["향미 태그"],
              "acidity": 1-5,
              "body": 1-5,
              "sweetness": 1-5,
              "description": "2-3문장 특징 설명",
              "recommendedBrewMethod": "추천 추출 방식",
              "isEstimated": true/false,
              "recipe": {
                "grindSize": "코만단테 C40 기준 클릭 또는 분쇄도 설명",
                "waterTemp": 93,
                "ratio": "1:15",
                "totalBrewTimeSec": 150,
                "steps": [
                  { "order": 1, "label": "뜸들이기", "waterAmount": 30, "durationSec": 30, "instruction": "설명" }
                ]
              }
            }
            """
        ]
        return lines.joined(separator: "\n")
    }

    private func cleanJSONText(_ text: String) -> String {
        var result = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if result.hasPrefix("```json") {
            result = result.replacingOccurrences(of: "```json", with: "")
        }
        if result.hasPrefix("```") {
            result = result.replacingOccurrences(of: "```", with: "")
        }
        if result.hasSuffix("```") {
            result = String(result.dropLast(3))
        }
        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func parseAPIError(from data: Data) -> String? {
        struct ErrorBody: Decodable {
            struct Detail: Decodable {
                let message: String?
            }
            let error: Detail?
        }
        guard let body = try? decoder.decode(ErrorBody.self, from: data),
              let message = body.error?.message else { return nil }
        return message
    }
}

private struct GeminiGenerateRequest: Encodable {
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

private struct GeminiGenerateResponse: Decodable {
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
extension BeanAnalysis {
    static let preview = BeanAnalysis(
        flavorNotes: ["베리", "플로럴", "시트러스"],
        acidity: 4,
        body: 3,
        sweetness: 4,
        description: "밝은 산미와 꽃향이 조화로운 원두입니다. 깔끔한 피니시가 특징입니다.",
        recommendedBrewMethod: "V60 핸드드립",
        isEstimated: false,
        recipe: SuggestedRecipe(
            grindSize: "코만단테 C40 22클릭",
            waterTemp: 93,
            ratio: "1:15",
            totalBrewTimeSec: 150,
            steps: [
                BrewStep(order: 1, label: "뜸들이기", waterAmount: 30, durationSec: 30, instruction: "중심에 부드럽게"),
                BrewStep(order: 2, label: "1차 주수", waterAmount: 100, durationSec: 45, instruction: "나선형으로 균일하게")
            ]
        )
    )
}
#endif
