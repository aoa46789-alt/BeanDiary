import SwiftUI

struct BrewRecipeSummaryBar: View {
    let recipe: ParsedRecipe

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                chip("\(formatGrams(recipe.coffeeGrams))g", icon: "leaf")
                if let temp = recipe.waterTemp {
                    chip("\(temp)°C", icon: "thermometer.medium")
                }
                if let ratio = recipe.ratio {
                    chip(ratio, icon: "drop")
                }
                if let dripper = recipe.dripper {
                    chip(dripper, icon: "funnel")
                }
                if let clicks = recipe.convertedGrindClicks {
                    chip("\(clicks)클릭", icon: "dial.medium")
                } else if let grind = recipe.sourceGrindSetting {
                    chip(grind, icon: "dial.medium")
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private func chip(_ text: String, icon: String) -> some View {
        Label(text, systemImage: icon)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial, in: Capsule())
    }

    private func formatGrams(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", value) : String(format: "%.1f", value)
    }
}

#Preview {
    BrewRecipeSummaryBar(recipe: ParsedRecipeDraft.preview.toParsedRecipe(
        beanName: "테스트",
        sourceType: "youtube",
        videoId: nil,
        userGrinder: "Comandante C40"
    ))
    .padding()
}
