import ActivityKit
import Foundation

@MainActor
enum BrewLiveActivityService {
    private static var activity: Activity<BrewActivityAttributes>?

    static var isSupported: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }

    static func sync(with viewModel: BrewGuideViewModel) {
        guard isSupported else { return }

        switch viewModel.phase {
        case .ready:
            end(immediately: true)
        case .brewing, .paused:
            if activity == nil {
                start(with: viewModel)
            } else {
                update(with: viewModel)
            }
        case .finished:
            end(with: viewModel, immediately: false)
        }
    }

    private static func start(with viewModel: BrewGuideViewModel) {
        end(immediately: true)

        let attributes = BrewActivityAttributes(
            beanName: viewModel.beanName,
            totalSteps: viewModel.steps.count,
            coffeeGrams: viewModel.recipe.coffeeGrams,
            dripper: viewModel.recipe.dripper,
            ratio: viewModel.recipe.ratio
        )

        do {
            activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState(from: viewModel), staleDate: nil),
                pushType: nil
            )
        } catch {
            activity = nil
        }
    }

    private static func update(with viewModel: BrewGuideViewModel) {
        guard let activity else { return }
        let state = contentState(from: viewModel)
        Task {
            await activity.update(.init(state: state, staleDate: nil))
        }
    }

    private static func end(with viewModel: BrewGuideViewModel? = nil, immediately: Bool) {
        guard let activity else { return }
        let state = viewModel.map(contentState(from:)) ?? BrewActivityAttributes.ContentState(
            phase: .finished,
            currentStepIndex: 0,
            stepLabel: "완료",
            stepRemainingSec: 0,
            stepEndDate: nil,
            waterAmount: nil,
            instruction: "",
            totalRemainingSec: 0,
            overallProgress: 1
        )
        Task {
            await activity.end(
                .init(state: state, staleDate: nil),
                dismissalPolicy: immediately ? .immediate : .default
            )
        }
        self.activity = nil
    }

    private static func contentState(from viewModel: BrewGuideViewModel) -> BrewActivityAttributes.ContentState {
        let step = viewModel.currentStep
        let phase: BrewActivityPhase = switch viewModel.phase {
        case .brewing: .brewing
        case .paused: .paused
        case .finished: .finished
        case .ready: .paused
        }

        return BrewActivityAttributes.ContentState(
            phase: phase,
            currentStepIndex: viewModel.currentStepIndex,
            stepLabel: step?.label ?? "추출",
            stepRemainingSec: viewModel.stepRemainingSec,
            stepEndDate: viewModel.stepEndDate,
            waterAmount: step?.waterAmount,
            instruction: step?.instruction ?? "",
            totalRemainingSec: viewModel.totalRemainingSec,
            overallProgress: viewModel.overallProgress
        )
    }
}
