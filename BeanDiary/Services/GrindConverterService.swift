import Foundation

enum GrindConverterService {
    private struct DialPoint {
        let dial: Double
        let clicks: Int
    }

    private struct ConversionFile: Decodable {
        let ek43ToComandanteC40: [FilePoint]

        enum CodingKeys: String, CodingKey {
            case ek43ToComandanteC40 = "ek43_to_comandante_c40"
        }

        struct FilePoint: Decodable {
            let dial: Double
            let clicks: Int
        }
    }

    private static let table: [DialPoint] = {
        if let url = Bundle.main.url(forResource: "grind_conversion", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decoded = try? JSONDecoder().decode(ConversionFile.self, from: data) {
            return decoded.ek43ToComandanteC40
                .map { DialPoint(dial: $0.dial, clicks: $0.clicks) }
                .sorted { $0.dial < $1.dial }
        }
        return [
            DialPoint(dial: 2.0, clicks: 18),
            DialPoint(dial: 2.5, clicks: 22),
            DialPoint(dial: 3.0, clicks: 25)
        ]
    }()

    static func parseDial(from setting: String) -> Double? {
        let pattern = /(\d+(?:\.\d+)?)/
        if let match = setting.firstMatch(of: pattern) {
            return Double(match.1)
        }
        return nil
    }

    static func convertEK43ToComandante(dial: Double) -> Int {
        let points = table
        guard let first = points.first else { return Int(dial * 8) }
        if dial <= first.dial { return first.clicks }
        guard let last = points.last else { return first.clicks }
        if dial >= last.dial { return last.clicks }

        for index in 0..<(points.count - 1) {
            let lower = points[index]
            let upper = points[index + 1]
            if dial >= lower.dial && dial <= upper.dial {
                let ratio = (dial - lower.dial) / (upper.dial - lower.dial)
                return Int((Double(lower.clicks) + ratio * Double(upper.clicks - lower.clicks)).rounded())
            }
        }
        return last.clicks
    }

    static func applyGrindConversion(
        sourceGrinder: String?,
        sourceGrindSetting: String?,
        targetGrinder: String = "Comandante C40"
    ) -> (clicks: Int?, note: String?) {
        guard let setting = sourceGrindSetting, !setting.isEmpty else {
            return (nil, nil)
        }

        let grinder = (sourceGrinder ?? "").lowercased()
        if grinder.contains("ek") || setting.lowercased().contains("ek") {
            if let dial = parseDial(from: setting) {
                let clicks = convertEK43ToComandante(dial: dial)
                let note = "EK43 dial \(dial) → \(targetGrinder) \(clicks)클릭 (참고값)"
                return (clicks, note)
            }
        }

        if grinder.contains("comandante") || grinder.contains("c40") || setting.contains("클릭") {
            if let value = parseDial(from: setting) {
                return (Int(value), "원본 그라인더가 이미 \(targetGrinder) 기준입니다.")
            }
        }

        return (nil, "환산표에 없는 그라인더입니다. 수동으로 확인하세요.")
    }
}
