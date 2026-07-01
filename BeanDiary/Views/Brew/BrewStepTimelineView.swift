import SwiftUI

struct BrewStepTimelineView: View {
    let steps: [BrewStep]
    let currentIndex: Int
    let completedIndices: Set<Int>
    let phase: BrewGuidePhase

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    stepIndicator(for: index)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(step.label)
                            .font(index == currentIndex && phase != .ready ? .subheadline.weight(.semibold) : .subheadline)
                            .foregroundStyle(index == currentIndex && phase != .ready ? .primary : .secondary)
                        HStack(spacing: 8) {
                            if let water = step.waterAmount {
                                Text("\(water)g")
                            }
                            Text("\(step.durationSec)초")
                        }
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    }
                    Spacer()
                }
                .padding(.vertical, 8)

                if index < steps.count - 1 {
                    Rectangle()
                        .fill(lineColor(for: index))
                        .frame(width: 2, height: 16)
                        .padding(.leading, 11)
                }
            }
        }
    }

    @ViewBuilder
    private func stepIndicator(for index: Int) -> some View {
        let size: CGFloat = 24
        if completedIndices.contains(index) || (phase == .finished && index <= currentIndex) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.system(size: size))
        } else if index == currentIndex && (phase == .brewing || phase == .paused) {
            Image(systemName: "circle.inset.filled")
                .foregroundStyle(.orange)
                .font(.system(size: size))
        } else {
            Image(systemName: "circle")
                .foregroundStyle(.secondary.opacity(0.4))
                .font(.system(size: size))
        }
    }

    private func lineColor(for index: Int) -> Color {
        if completedIndices.contains(index) {
            return .green.opacity(0.5)
        }
        return .secondary.opacity(0.2)
    }
}

#Preview {
    BrewStepTimelineView(
        steps: ParsedRecipeDraft.preview.steps,
        currentIndex: 1,
        completedIndices: [0],
        phase: .brewing
    )
    .padding()
}
