import SwiftUI

struct BeanAnalysisCard: View {
    let analysis: BeanAnalysis
    let fetchedAt: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("AI 분석", systemImage: "sparkles")
                    .font(.headline)
                Spacer()
                if analysis.isEstimated {
                    Text("AI 추정")
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.orange.opacity(0.15), in: Capsule())
                        .foregroundStyle(.orange)
                }
            }

            if let fetchedAt {
                Text("분석 시각: \(DateFormatting.fullFormatter.string(from: fetchedAt))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(analysis.description)
                .font(.body)

            if !analysis.flavorNotes.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(analysis.flavorNotes, id: \.self) { note in
                        Text(note)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                }
            }

            VStack(spacing: 10) {
                FlavorScoreRow(label: "산미", value: analysis.acidity, color: .orange)
                FlavorScoreRow(label: "바디", value: analysis.body, color: .brown)
                FlavorScoreRow(label: "단맛", value: analysis.sweetness, color: .pink)
            }

            LabeledContent("추천 추출", value: analysis.recommendedBrewMethod)

            if let recipe = analysis.recipe {
                Divider()
                Text("추천 레시피")
                    .font(.subheadline.weight(.semibold))

                if let grind = recipe.grindSize {
                    LabeledContent("분쇄도", value: grind)
                }
                if let temp = recipe.waterTemp {
                    LabeledContent("물 온도", value: "\(temp)°C")
                }
                if let ratio = recipe.ratio {
                    LabeledContent("비율", value: ratio)
                }
                if let total = recipe.totalBrewTimeSec {
                    LabeledContent("총 시간", value: formatDuration(total))
                }

                if let steps = recipe.steps, !steps.isEmpty {
                    ForEach(steps) { step in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(step.order)")
                                .font(.caption.monospacedDigit())
                                .frame(width: 20, height: 20)
                                .background(.secondary.opacity(0.15), in: Circle())
                            VStack(alignment: .leading, spacing: 2) {
                                Text(step.label)
                                    .font(.subheadline.weight(.medium))
                                Text(step.instruction)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                HStack(spacing: 12) {
                                    if let water = step.waterAmount {
                                        Text("\(water)g")
                                    }
                                    Text("\(step.durationSec)초")
                                }
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return minutes > 0 ? "\(minutes)분 \(secs)초" : "\(secs)초"
    }
}

private struct FlavorScoreRow: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .frame(width: 36, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.systemGray5))
                    Capsule()
                        .fill(color.gradient)
                        .frame(width: geo.size.width * CGFloat(value) / 5)
                }
            }
            .frame(height: 8)
            Text("\(value)/5")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 32, alignment: .trailing)
        }
    }
}

/// 간단한 태그 플로우 레이아웃
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}

#Preview {
    ScrollView {
        BeanAnalysisCard(analysis: .preview, fetchedAt: .now)
            .padding()
    }
}
