import SwiftData
import SwiftUI

struct RecipeSearchView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("primaryGrinder") private var primaryGrinder = "Comandante C40"

    @State private var viewModel: RecipeSearchViewModel

    init(bean: CoffeeBean, recommendedBrewMethod: String? = nil) {
        _viewModel = State(initialValue: RecipeSearchViewModel(
            bean: bean,
            recommendedBrewMethod: recommendedBrewMethod
        ))
    }

    var body: some View {
        List {
            OfflineBanner()
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

            Section {
                LabeledContent("검색어", value: viewModel.searchQuery)
                if !YouTubeConfiguration.isConfigured {
                    Text("YouTube API 키가 필요합니다. Gemini 키와 동일한 Google Cloud 키를 사용할 수 있습니다 (YouTube Data API v3 활성화 필요).")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let recipe = viewModel.selectedRecipe {
                Section("분석 결과") {
                    ParsedRecipeCard(recipe: recipe)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)

                    if !recipe.brewSteps.isEmpty || recipe.totalBrewTimeSec != nil {
                        NavigationLink {
                            BrewGuideView(recipe: recipe, bean: viewModel.bean)
                        } label: {
                            Label("추출 가이드 시작", systemImage: "timer")
                        }
                    }
                }
            }

            Section {
                if viewModel.isSearching {
                    HStack {
                        ProgressView()
                        Text("YouTube 검색 중…")
                    }
                } else if viewModel.videos.isEmpty {
                    ContentUnavailableView(
                        "영상 없음",
                        systemImage: "play.rectangle",
                        description: Text("검색 버튼을 눌러 레시피 영상을 찾아보세요.")
                    )
                } else {
                    ForEach(viewModel.videos) { video in
                        YouTubeVideoRow(
                            video: video,
                            isParsing: viewModel.isParsing && viewModel.parsingVideoId == video.videoId,
                            onPlay: { viewModel.playerVideo = video },
                            onParse: {
                                Task {
                                    await viewModel.parseVideo(
                                        video,
                                        context: modelContext,
                                        userGrinder: primaryGrinder
                                    )
                                }
                            }
                        )
                    }
                }
            } header: {
                Text("YouTube 레시피")
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("레시피")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await viewModel.search(context: modelContext) }
                } label: {
                    Label("검색", systemImage: "magnifyingglass")
                }
                .disabled(viewModel.isSearching || !YouTubeConfiguration.isConfigured)
            }
        }
        .sheet(item: $viewModel.playerVideo) { video in
            YouTubeEmbedPlayerView(video: video)
        }
        .task {
            if viewModel.videos.isEmpty && YouTubeConfiguration.isConfigured {
                await viewModel.search(context: modelContext)
            }
        }
    }
}

#Preview {
    NavigationStack {
        RecipeSearchView(bean: PreviewData.sampleBean, recommendedBrewMethod: "V60 핸드드립")
    }
    .modelContainer(PreviewData.container)
}
