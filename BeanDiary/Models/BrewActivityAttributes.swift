import ActivityKit
import Foundation

struct BrewActivityAttributes: ActivityAttributes {
    var beanName: String
    var totalSteps: Int
    var coffeeGrams: Double?
    var dripper: String?
    var ratio: String?

    struct ContentState: Codable, Hashable {
        var phase: BrewActivityPhase
        var currentStepIndex: Int
        var stepLabel: String
        var stepRemainingSec: Int
        var stepEndDate: Date?
        var waterAmount: Int?
        var instruction: String
        var totalRemainingSec: Int
        var overallProgress: Double
    }
}

enum BrewActivityPhase: String, Codable, Hashable {
    case brewing
    case paused
    case finished
}

enum BrewActivityFormatting {
    static func time(_ seconds: Int) -> String {
        let minutes = max(0, seconds) / 60
        let secs = max(0, seconds) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}
