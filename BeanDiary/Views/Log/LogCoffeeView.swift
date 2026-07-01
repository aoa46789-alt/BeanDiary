import SwiftData
import SwiftUI

struct LogCoffeeView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \CoffeeBean.name) private var beans: [CoffeeBean]

    @State private var beanName = ""
    @State private var brewMethod = BrewMethod.handDrip
    @State private var drankAt = Date()
    @State private var rating = 3
    @State private var grindSize = ""
    @State private var waterTemp = ""
    @State private var ratio = ""
    @State private var tastingNote = ""
    @State private var pendingMedia: [PendingMediaItem] = []
    @State private var capturedAtOverrides: [UUID: Date] = [:]
    @State private var showSavedAlert = false
    @State private var showSaveErrorAlert = false
    @State private var saveError: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("원두") {
                    TextField("원두 이름", text: $beanName)
                    if !beanSuggestions.isEmpty && !beanName.isEmpty {
                        ForEach(beanSuggestions, id: \.self) { suggestion in
                            Button(suggestion) {
                                beanName = suggestion
                            }
                            .foregroundStyle(.primary)
                        }
                    }
                }

                Section("추출") {
                    Picker("방식", selection: $brewMethod) {
                        ForEach(BrewMethod.allCases) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    DatePicker("마신 시각", selection: $drankAt, displayedComponents: [.date, .hourAndMinute])
                    TextField("분쇄도 (예: 코만단테 22클릭)", text: $grindSize)
                    TextField("물 온도 (°C)", text: $waterTemp)
                        .keyboardType(.numberPad)
                    TextField("비율 (예: 1:15)", text: $ratio)
                }

                Section("평가") {
                    RatingView(rating: $rating)
                    TextField("시음 메모", text: $tastingNote, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    MediaPickerSection(
                        pendingItems: $pendingMedia,
                        capturedAtOverrides: $capturedAtOverrides
                    )
                }

                Section {
                    Button("기록 저장") {
                        saveLog()
                    }
                    .disabled(beanName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("커피 기록")
            .alert("저장 완료", isPresented: $showSavedAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text("커피 기록이 저장되었습니다.")
            }
            .alert("저장 실패", isPresented: $showSaveErrorAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(saveError ?? "알 수 없는 오류")
            }
        }
    }

    private var beanSuggestions: [String] {
        let query = beanName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return [] }
        return beans
            .map(\.name)
            .filter { $0.lowercased().contains(query) && $0.lowercased() != query }
            .prefix(5)
            .map { $0 }
    }

    private func saveLog() {
        let trimmedName = beanName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let bean = BeanService.findOrCreate(name: trimmedName, in: modelContext)
        let temp = Int(waterTemp.trimmingCharacters(in: .whitespacesAndNewlines))

        let log = CoffeeLog(
            drankAt: drankAt,
            brewMethod: brewMethod.rawValue,
            rating: rating,
            grindSize: grindSize.isEmpty ? nil : grindSize,
            waterTemp: temp,
            ratio: ratio.isEmpty ? nil : ratio,
            tastingNote: tastingNote.isEmpty ? nil : tastingNote,
            bean: bean
        )
        modelContext.insert(log)

        for item in pendingMedia {
            let capturedAt = capturedAtOverrides[item.id] ?? item.capturedAt
            let attachment = DiaryAttachment(
                mediaType: item.mediaType,
                fileName: item.fileName,
                thumbnailFileName: item.thumbnailFileName,
                capturedAt: capturedAt,
                durationSec: item.durationSec,
                coffeeLog: log
            )
            modelContext.insert(attachment)
            log.attachments.append(attachment)
        }

        do {
            try modelContext.save()
            resetForm()
            showSavedAlert = true
        } catch {
            saveError = error.localizedDescription
            showSaveErrorAlert = true
        }
    }

    private func resetForm() {
        beanName = ""
        brewMethod = .handDrip
        drankAt = .now
        rating = 3
        grindSize = ""
        waterTemp = ""
        ratio = ""
        tastingNote = ""
        pendingMedia = []
        capturedAtOverrides = [:]
    }
}

#Preview {
    LogCoffeeView()
        .modelContainer(PreviewData.container)
}
