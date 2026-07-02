import SwiftData
import SwiftUI

struct BeanDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var bean: CoffeeBean

    @State private var viewModel = BeanDetailViewModel()

    var body: some View {
        Form {
            OfflineBanner()
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

            Section("원두 정보") {
                TextField("이름", text: $bean.name)
                TextField("로스터리", text: optionalBinding(\.roaster))
                TextField("산지", text: optionalBinding(\.origin))
                TextField("로스팅", text: optionalBinding(\.roastLevel))
                LabeledContent("기록 횟수", value: "\(bean.logs.count)회")
            }

            Section {
                if !GeminiConfiguration.isConfigured {
                    ContentUnavailableView {
                        Label("API 키 필요", systemImage: "key.fill")
                    } description: {
                        Text("더보기 → 설정에서 Gemini API 키를 입력하면 AI 분석을 사용할 수 있습니다.")
                    }
                } else if viewModel.isLoading {
                    HStack {
                        ProgressView()
                        Text("Gemini가 원두를 분석하는 중…")
                            .foregroundStyle(.secondary)
                    }
                } else if let analysis = viewModel.analysis {
                    BeanAnalysisCard(analysis: analysis, fetchedAt: bean.analysisFetchedAt)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                } else {
                    ContentUnavailableView {
                        Label("분석 없음", systemImage: "sparkles")
                    } description: {
                        Text("AI 분석 버튼을 눌러 향미 프로필과 추천 레시피를 확인하세요.")
                    }
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            if GeminiConfiguration.isConfigured {
                Section {
                    Button {
                        Task {
                            if viewModel.analysis == nil {
                                await viewModel.analyze(bean: bean, context: modelContext)
                            } else {
                                await viewModel.analyze(bean: bean, context: modelContext, forceRefresh: true)
                            }
                        }
                    } label: {
                        Label(
                            viewModel.analysis == nil ? "AI 분석 시작" : "다시 분석",
                            systemImage: viewModel.analysis == nil ? "sparkles" : "arrow.clockwise"
                        )
                    }
                    .disabled(viewModel.isLoading)
                }
            }

            Section("레시피") {
                NavigationLink {
                    RecipeSearchView(
                        bean: bean,
                        recommendedBrewMethod: viewModel.analysis?.recommendedBrewMethod
                    )
                } label: {
                    Label("YouTube 레시피 찾기", systemImage: "play.rectangle")
                }
            }
        }
        .navigationTitle(bean.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadCached(from: bean)
        }
    }

    private func optionalBinding(_ keyPath: ReferenceWritableKeyPath<CoffeeBean, String?>) -> Binding<String> {
        Binding(
            get: { bean[keyPath: keyPath] ?? "" },
            set: { bean[keyPath: keyPath] = $0.isEmpty ? nil : $0 }
        )
    }
}

#Preview {
    NavigationStack {
        BeanDetailView(bean: PreviewData.sampleBean)
    }
    .modelContainer(PreviewData.container)
}
