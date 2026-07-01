import SwiftData
import SwiftUI

struct BrewGuideView: View {
    let recipe: ParsedRecipe
    let bean: CoffeeBean

    @State private var viewModel: BrewGuideViewModel
    @State private var showTastingNote = false

    init(recipe: ParsedRecipe, bean: CoffeeBean) {
        self.recipe = recipe
        self.bean = bean
        _viewModel = State(initialValue: BrewGuideViewModel(recipe: recipe, beanName: bean.name))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                BrewRecipeSummaryBar(recipe: recipe)

                if viewModel.phase == .finished {
                    completionHeader
                } else {
                    timerSection
                }

                if let step = viewModel.currentStep, viewModel.phase != .ready {
                    stepDetailCard(step)
                }

                ProgressView(value: viewModel.overallProgress)
                    .tint(.orange)

                HStack {
                    Text("전체 남은 시간")
                    Spacer()
                    Text(formatTime(viewModel.totalRemainingSec))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                .font(.caption)

                BrewStepTimelineView(
                    steps: viewModel.steps,
                    currentIndex: viewModel.currentStepIndex,
                    completedIndices: viewModel.completedStepIndices,
                    phase: viewModel.phase
                )

                controlButtons
            }
            .padding()
        }
        .navigationTitle(bean.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showTastingNote) {
            TastingNoteView(recipe: recipe, bean: bean)
        }
    }

    private var completionHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.green)
            Text("추출 완료!")
                .font(.title2.bold())
            Text("시음 노트를 남겨보세요.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }

    private var timerSection: some View {
        VStack(spacing: 8) {
            if viewModel.phase == .ready {
                Text("준비")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(formatTime(viewModel.steps.first?.durationSec ?? 0))
                    .font(.system(size: 64, weight: .light, design: .rounded))
                    .monospacedDigit()
            } else {
                Text(viewModel.currentStep?.label ?? "")
                    .font(.headline)
                TimelineView(.periodic(from: .now, by: 1)) { _ in
                    Text(formatTime(viewModel.stepRemainingSec))
                        .font(.system(size: 72, weight: .light, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(viewModel.phase == .paused ? .secondary : .primary)
                        .onAppear { viewModel.refreshRemainingFromClock() }
                }
                if viewModel.phase == .paused {
                    Text("일시정지")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func stepDetailCard(_ step: BrewStep) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let water = step.waterAmount {
                Label("목표 물량 \(water)g", systemImage: "drop.fill")
                    .font(.subheadline)
            }
            Text(step.instruction)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var controlButtons: some View {
        switch viewModel.phase {
        case .ready:
            Button {
                viewModel.start()
            } label: {
                Label("추출 시작", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(viewModel.steps.isEmpty)

        case .brewing, .paused:
            HStack(spacing: 12) {
                Button { viewModel.goToPreviousStep() } label: {
                    Image(systemName: "backward.fill")
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.currentStepIndex == 0)

                Button { viewModel.togglePause() } label: {
                    Label(viewModel.phase == .paused ? "재개" : "일시정지",
                          systemImage: viewModel.phase == .paused ? "play.fill" : "pause.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button { viewModel.goToNextStep() } label: {
                    Image(systemName: "forward.fill")
                }
                .buttonStyle(.bordered)
            }

            Button("추출 취소", role: .destructive) {
                viewModel.cancel()
            }
            .font(.caption)

        case .finished:
            Button {
                showTastingNote = true
            } label: {
                Label("시음 노트 작성", systemImage: "note.text")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}

#Preview {
    NavigationStack {
        BrewGuideView(
            recipe: ParsedRecipeDraft.preview.toParsedRecipe(
                beanName: "에티오피아",
                sourceType: "youtube",
                videoId: "x",
                userGrinder: "Comandante C40"
            ),
            bean: PreviewData.sampleBean
        )
    }
}
