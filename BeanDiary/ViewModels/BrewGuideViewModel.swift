import Foundation
import UIKit

enum BrewGuidePhase: Equatable {
    case ready
    case brewing
    case paused
    case finished
}

enum BrewHapticService {
    static func stepCompleted() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func brewCompleted() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

@MainActor
@Observable
final class BrewGuideViewModel {
    let recipe: ParsedRecipe
    let beanName: String

    private(set) var steps: [BrewStep]
    var currentStepIndex = 0
    var stepRemainingSec = 0
    var phase: BrewGuidePhase = .ready
    private(set) var completedStepIndices: Set<Int> = []

    private var stepEndTime: Date?
    private var timerTask: Task<Void, Never>?

    init(recipe: ParsedRecipe, beanName: String) {
        self.recipe = recipe
        self.beanName = beanName
        let parsed = recipe.brewSteps.sorted { $0.order < $1.order }
        if parsed.isEmpty, let total = recipe.totalBrewTimeSec, total > 0 {
            steps = [
                BrewStep(
                    order: 1,
                    label: "추출",
                    waterAmount: recipe.waterGrams.map { Int($0) },
                    durationSec: total,
                    instruction: "레시피대로 추출하세요."
                )
            ]
        } else {
            steps = parsed
        }
    }

    var currentStep: BrewStep? {
        guard steps.indices.contains(currentStepIndex) else { return nil }
        return steps[currentStepIndex]
    }

    var totalRemainingSec: Int {
        guard steps.indices.contains(currentStepIndex) else { return 0 }
        let future = steps[(currentStepIndex + 1)...].reduce(0) { $0 + $1.durationSec }
        return stepRemainingSec + future
    }

    var overallProgress: Double {
        guard !steps.isEmpty else { return 0 }
        let total = steps.reduce(0) { $0 + $1.durationSec }
        guard total > 0 else { return phase == .finished ? 1 : 0 }
        let elapsed = steps.prefix(currentStepIndex).reduce(0) { $0 + $1.durationSec }
        let currentElapsed = (currentStep?.durationSec ?? 0) - stepRemainingSec
        return min(1, Double(elapsed + currentElapsed) / Double(total))
    }

    func start() {
        guard !steps.isEmpty else { return }
        completedStepIndices = []
        currentStepIndex = 0
        phase = .brewing
        beginStep(at: 0)
        startTimerLoop()
    }

    func togglePause() {
        switch phase {
        case .brewing:
            phase = .paused
            if let end = stepEndTime {
                stepRemainingSec = max(0, Int(end.timeIntervalSinceNow.rounded(.up)))
            }
            stepEndTime = nil
            timerTask?.cancel()
        case .paused:
            phase = .brewing
            stepEndTime = Date().addingTimeInterval(TimeInterval(stepRemainingSec))
            startTimerLoop()
        default:
            break
        }
    }

    func goToPreviousStep() {
        guard currentStepIndex > 0 else { return }
        completedStepIndices.remove(currentStepIndex - 1)
        beginStep(at: currentStepIndex - 1)
        if phase == .brewing {
            startTimerLoop()
        }
    }

    func goToNextStep() {
        guard currentStepIndex < steps.count - 1 else {
            finishBrew()
            return
        }
        completedStepIndices.insert(currentStepIndex)
        beginStep(at: currentStepIndex + 1)
        if phase == .brewing {
            startTimerLoop()
        }
    }

    func cancel() {
        timerTask?.cancel()
        timerTask = nil
        stepEndTime = nil
        phase = .ready
        currentStepIndex = 0
        stepRemainingSec = steps.first?.durationSec ?? 0
        completedStepIndices = []
    }

    func refreshRemainingFromClock() {
        guard phase == .brewing, let end = stepEndTime else { return }
        stepRemainingSec = max(0, Int(end.timeIntervalSinceNow.rounded(.up)))
        if stepRemainingSec == 0 {
            completeCurrentStep()
        }
    }

    private func beginStep(at index: Int) {
        currentStepIndex = index
        stepRemainingSec = steps[index].durationSec
        if phase == .brewing {
            stepEndTime = Date().addingTimeInterval(TimeInterval(stepRemainingSec))
        }
    }

    private func startTimerLoop() {
        timerTask?.cancel()
        timerTask = Task { @MainActor in
            while !Task.isCancelled, phase == .brewing {
                try? await Task.sleep(for: .seconds(1))
                refreshRemainingFromClock()
            }
        }
    }

    private func completeCurrentStep() {
        BrewHapticService.stepCompleted()
        completedStepIndices.insert(currentStepIndex)

        if currentStepIndex >= steps.count - 1 {
            finishBrew()
            return
        }

        beginStep(at: currentStepIndex + 1)
    }

    private func finishBrew() {
        timerTask?.cancel()
        timerTask = nil
        stepEndTime = nil
        stepRemainingSec = 0
        phase = .finished
        BrewHapticService.brewCompleted()
    }
}
