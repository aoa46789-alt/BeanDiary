import SwiftData
import SwiftUI

struct CafeDetailSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    @Bindable var spot: CafeSpot
    var viewModel: CafeMapViewModel

    @State private var showHideOptions = false
    @State private var connectivity = ConnectivityMonitor.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    badges
                    statsSection
                    previewSection
                    noteSection
                    actionButtons
                    tagToggles
                }
                .padding()
            }
            .navigationTitle(spot.name)
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("숨기기", isPresented: $showHideOptions, titleVisibility: .visible) {
                Button("별로였어요", role: .destructive) {
                    CafeMapService.markHidden(spot, reason: CafeHiddenReason.notTasty)
                    save()
                }
                Button("드립 전문점이 아니에요", role: .destructive) {
                    CafeMapService.markHidden(spot, reason: CafeHiddenReason.notDripSpecialty)
                    save()
                }
                Button("취소", role: .cancel) {}
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .task {
            guard spot.cafePreview == nil, shouldOfferPreview, GeminiConfiguration.isConfigured,
                  connectivity.isOnline else { return }
            await viewModel.fetchPreview(for: spot, context: modelContext)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let address = spot.address {
                Label(address, systemImage: "mappin.and.ellipse")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            if let phone = spot.phone {
                Label(phone, systemImage: "phone")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var badges: some View {
        HStack(spacing: 8) {
            if spot.isColumbusGuide {
                badge("콜럼버스 가이드", .purple)
            }
            if spot.isDripSpecialty == true {
                badge("드립 전문", .orange)
            }
            if spot.isOnMap {
                badge(CafeVisitStatus.displayNames[spot.visitStatus] ?? spot.visitStatus, .green)
            }
        }
    }

    private var statsSection: some View {
        HStack {
            if spot.visitCount > 0 {
                LabeledContent("방문", value: "\(spot.visitCount)회")
            }
            if let last = spot.lastVisitedAt {
                LabeledContent("마지막", value: DateFormatting.dayHeaderFormatter.string(from: last))
            }
        }
        .font(.caption)
    }

    @ViewBuilder
    private var previewSection: some View {
        if let preview = spot.cafePreview {
            VStack(alignment: .leading, spacing: 10) {
                CafePreviewCard(preview: preview, fetchedAt: spot.previewFetchedAt)
                previewActions
            }
        } else if shouldOfferPreview {
            VStack(alignment: .leading, spacing: 8) {
                OfflineBanner()
                Button {
                    Task { await viewModel.fetchPreview(for: spot, context: modelContext) }
                } label: {
                    Label("AI 미리보기 불러오기", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.isLoadingPreview || !GeminiConfiguration.isConfigured || !connectivity.isOnline)

                if !connectivity.isOnline {
                    Text("네트워크 연결 후 미리보기를 불러올 수 있습니다.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if viewModel.isLoadingPreview {
                    ProgressView("카페 정보 분석 중…")
                }
                if let error = viewModel.previewError {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
            }
        }
    }

    private var shouldOfferPreview: Bool {
        spot.isColumbusGuide || spot.isDripSpecialty == true || spot.visitStatus == CafeVisitStatus.wishlist
    }

    private var previewActions: some View {
        Button {
            Task { await viewModel.fetchPreview(for: spot, context: modelContext, forceRefresh: true) }
        } label: {
            Label("미리보기 새로고침", systemImage: "arrow.clockwise")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .disabled(viewModel.isLoadingPreview || !GeminiConfiguration.isConfigured || !connectivity.isOnline)
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("개인 메모")
                .font(.subheadline.weight(.semibold))
            TextField("메모", text: Binding(
                get: { spot.personalNote ?? "" },
                set: { spot.personalNote = $0.isEmpty ? nil : $0 }
            ), axis: .vertical)
            .lineLimit(2...4)
            .textFieldStyle(.roundedBorder)
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button {
                    CafeMapService.markLiked(spot)
                    save()
                } label: {
                    Label("맛있었어요", systemImage: "hand.thumbsup.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    CafeMapService.markWishlist(spot)
                    save()
                } label: {
                    Label("방문 예정", systemImage: "bookmark.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            HStack(spacing: 10) {
                Button { showHideOptions = true } label: {
                    Label("숨기기", systemImage: "eye.slash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                if !spot.isOnMap {
                    Button {
                        CafeMapService.restoreToMap(spot)
                        save()
                    } label: {
                        Label("지도에 복구", systemImage: "arrow.uturn.backward")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }

            HStack(spacing: 10) {
                if let url = spot.mapsURL {
                    Button {
                        openURL(url)
                    } label: {
                        Label("Apple 지도", systemImage: "map")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                if let url = spot.naverMapsURL {
                    Button {
                        openURL(url)
                    } label: {
                        Label("네이버 지도", systemImage: "location")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    private var tagToggles: some View {
        VStack(spacing: 8) {
            Toggle("콜럼버스 가이드 선정", isOn: $spot.isColumbusGuide)
                .onChange(of: spot.isColumbusGuide) { _, _ in save() }
            Toggle("드립 전문점", isOn: Binding(
                get: { spot.isDripSpecialty ?? false },
                set: { spot.isDripSpecialty = $0 }
            ))
            .onChange(of: spot.isDripSpecialty) { _, _ in save() }
        }
        .font(.subheadline)
    }

    private func badge(_ text: String, _ color: Color) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15), in: Capsule())
            .foregroundStyle(color)
    }

    private func save() {
        try? modelContext.save()
    }
}
