import SwiftUI

struct ParsedRecipeCard: View {
    let recipe: ParsedRecipe

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("파싱된 레시피", systemImage: "list.bullet.clipboard")
                .font(.headline)

            if recipe.sourceType == "youtube", let videoId = recipe.sourceVideoId {
                Text("YouTube · \(videoId)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                paramCell("원두", "\(formatGrams(recipe.coffeeGrams))g")
                if let water = recipe.waterGrams {
                    paramCell("물", "\(formatGrams(water))g")
                }
                if let ratio = recipe.ratio {
                    paramCell("비율", ratio)
                }
                if let temp = recipe.waterTemp {
                    paramCell("온도", "\(temp)°C")
                }
                if let dripper = recipe.dripper {
                    paramCell("드리퍼", dripper)
                }
                if let total = recipe.totalBrewTimeSec {
                    paramCell("총 시간", formatDuration(total))
                }
            }

            if let grinder = recipe.sourceGrinder, let setting = recipe.sourceGrindSetting {
                Divider()
                LabeledContent("원본 분쇄", value: "\(grinder) \(setting)")
            }

            if let clicks = recipe.convertedGrindClicks {
                LabeledContent("내 그라인더", value: "\(recipe.convertedGrinder) → \(clicks)클릭")
                if let note = recipe.grindConversionNote {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            let steps = recipe.brewSteps
            if !steps.isEmpty {
                Divider()
                Text("추출 단계")
                    .font(.subheadline.weight(.semibold))
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
                                if let water = step.waterAmount { Text("\(water)g") }
                                Text("\(step.durationSec)초")
                            }
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private func paramCell(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.medium))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formatGrams(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", value) : String(format: "%.1f", value)
    }

    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return minutes > 0 ? "\(minutes)분 \(secs)초" : "\(secs)초"
    }
}

#Preview {
    ParsedRecipeCard(recipe: ParsedRecipeDraft.preview.toParsedRecipe(
        beanName: "에티오피아 예가체프",
        sourceType: "youtube",
        videoId: "abc",
        userGrinder: "Comandante C40"
    ))
    .padding()
}
