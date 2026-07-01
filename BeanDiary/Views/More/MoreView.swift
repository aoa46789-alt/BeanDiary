import SwiftUI

struct MoreView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    HistoryView()
                } label: {
                    Label("기록 타임라인", systemImage: "clock.arrow.circlepath")
                }

                NavigationLink {
                    SettingsView()
                } label: {
                    Label("설정", systemImage: "gearshape.fill")
                }
            }
            .navigationTitle("더보기")
        }
    }
}

struct SettingsView: View {
    @AppStorage("primaryGrinder") private var primaryGrinder = "Comandante C40"

    private var storageText: String {
        let bytes = MediaStorageService.totalStorageBytes()
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }

    var body: some View {
        Form {
            Section("그라인더") {
                TextField("내 그라인더", text: $primaryGrinder)
            }

            Section("저장소") {
                LabeledContent("미디어 용량", value: storageText)
            }

            Section("앱 정보") {
                LabeledContent("버전", value: "0.1.0 (Phase 1)")
            }
        }
        .navigationTitle("설정")
    }
}

#Preview {
    MoreView()
}
