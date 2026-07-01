import SwiftData
import SwiftUI

struct TastingNoteView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let recipe: ParsedRecipe
    let bean: CoffeeBean

    @State private var rating = 3
    @State private var tastingNote = ""
    @State private var acidity = 3
    @State private var tastedBodyScore = 3
    @State private var sweetness = 3
    @State private var bitterness = 3
    @State private var showSavedAlert = false
    @State private var saveError: String?

    var body: some View {
        Form {
            Section {
                Text(bean.name)
                    .font(.headline)
                if let method = recipe.brewMethod {
                    Text(method)
                        .foregroundStyle(.secondary)
                }
            }

            Section("전체 평가") {
                RatingView(rating: $rating)
            }

            Section("시음 슬라이더") {
                TasteSliderRow(label: "산미", value: $acidity, color: .orange)
                TasteSliderRow(label: "바디", value: $tastedBodyScore, color: .brown)
                TasteSliderRow(label: "단맛", value: $sweetness, color: .pink)
                TasteSliderRow(label: "쓴맛", value: $bitterness, color: .gray)
            }

            Section("메모") {
                TextField("오늘 커피는 어땠나요?", text: $tastingNote, axis: .vertical)
                    .lineLimit(3...8)
            }

            Section {
                Button("기록 저장") {
                    saveLog()
                }
            }

            if let saveError {
                Section {
                    Text(saveError)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
        }
        .navigationTitle("시음 노트")
        .navigationBarTitleDisplayMode(.inline)
        .alert("저장 완료", isPresented: $showSavedAlert) {
            Button("확인") { dismiss() }
        } message: {
            Text("커피 기록이 저장되었습니다.")
        }
    }

    private func saveLog() {
        let grindText: String? = {
            if let clicks = recipe.convertedGrindClicks {
                return "\(recipe.convertedGrinder) \(clicks)클릭"
            }
            return recipe.sourceGrindSetting
        }()

        let log = CoffeeLog(
            drankAt: .now,
            brewMethod: recipe.brewMethod ?? BrewMethod.handDrip.rawValue,
            rating: rating,
            grindSize: grindText,
            waterTemp: recipe.waterTemp,
            ratio: recipe.ratio,
            tastingNote: tastingNote.isEmpty ? nil : tastingNote,
            tastedAcidity: acidity,
            tastedBody: tastedBodyScore,
            tastedSweetness: sweetness,
            tastedBitterness: bitterness,
            bean: bean,
            usedRecipe: recipe
        )
        modelContext.insert(log)

        do {
            try modelContext.save()
            showSavedAlert = true
        } catch {
            saveError = error.localizedDescription
        }
    }
}

struct TasteSliderRow: View {
    let label: String
    @Binding var value: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                Spacer()
                Text("\(value)/5")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)

            Slider(
                value: Binding(
                    get: { Double(value) },
                    set: { value = Int($0.rounded()) }
                ),
                in: 1...5,
                step: 1
            )
            .tint(color)
        }
    }
}

#Preview {
    NavigationStack {
        TastingNoteView(
            recipe: ParsedRecipeDraft.preview.toParsedRecipe(
                beanName: "에티오피아",
                sourceType: "youtube",
                videoId: nil,
                userGrinder: "Comandante C40"
            ),
            bean: PreviewData.sampleBean
        )
    }
    .modelContainer(PreviewData.container)
}
