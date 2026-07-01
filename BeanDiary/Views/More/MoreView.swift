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
    @AppStorage(GeminiConfiguration.apiKeyUserDefaultsKey) private var geminiApiKey = ""
    @AppStorage(YouTubeConfiguration.apiKeyUserDefaultsKey) private var youtubeApiKey = ""

    private var storageText: String {
        let bytes = MediaStorageService.totalStorageBytes()
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }

    var body: some View {
        Form {
            Section {
                SecureField("Gemini API 키", text: $geminiApiKey)
                    .textContentType(.password)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            } header: {
                Text("AI (Gemini)")
            } footer: {
                Text("Google AI Studio(aistudio.google.com)에서 API 키를 발급받아 입력하세요. 기기에만 저장됩니다.")
            }

            Section {
                SecureField("YouTube API 키 (선택)", text: $youtubeApiKey)
                    .textContentType(.password)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            } header: {
                Text("YouTube")
            } footer: {
                Text("Google Cloud Console에서 YouTube Data API v3를 활성화하세요. 비워두면 Gemini API 키를 재사용합니다.")
            }

            Section("그라인더") {
                TextField("내 그라인더", text: $primaryGrinder)
            }

            Section("저장소") {
                LabeledContent("미디어 용량", value: storageText)
            }

            Section("앱 정보") {
                LabeledContent("버전", value: "0.3.0 (Phase 3)")
            }
        }
        .navigationTitle("설정")
    }
}

#Preview {
    MoreView()
}
