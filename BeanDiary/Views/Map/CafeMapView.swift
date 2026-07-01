import MapKit
import SwiftData
import SwiftUI

struct CafeMapView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CafeSpot.name) private var allSpots: [CafeSpot]

    @State private var viewModel = CafeMapViewModel()

    private var filteredSpots: [CafeSpot] {
        viewModel.filteredSpots(from: allSpots)
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                if viewModel.showListMode {
                    CafeListView(spots: filteredSpots) { spot in
                        viewModel.select(spot)
                    }
                } else {
                    Map(position: $viewModel.cameraPosition) {
                        ForEach(filteredSpots, id: \.persistentModelID) { spot in
                            Annotation(spot.name, coordinate: spot.coordinate) {
                                Button {
                                    viewModel.select(spot)
                                } label: {
                                    CafePinView(spot: spot)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .mapStyle(.standard(elevation: .realistic))
                }

                if filteredSpots.isEmpty {
                    ContentUnavailableView(
                        "표시할 카페가 없어요",
                        systemImage: "mappin.slash",
                        description: Text("+ 버튼으로 카페를 추가하거나 필터를 변경하세요.")
                    )
                    .allowsHitTesting(false)
                }

                VStack(spacing: 12) {
                    Button {
                        viewModel.showListMode.toggle()
                    } label: {
                        Image(systemName: viewModel.showListMode ? "map.fill" : "list.bullet")
                            .font(.title3)
                            .frame(width: 48, height: 48)
                            .background(.ultraThinMaterial, in: Circle())
                    }

                    Button {
                        viewModel.showAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2.weight(.semibold))
                            .frame(width: 52, height: 52)
                            .background(Color.accentColor, in: Circle())
                            .foregroundStyle(.white)
                    }
                }
                .padding()
            }
            .navigationTitle("지도")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .top, spacing: 0) {
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("카페명, 지역 검색", text: $viewModel.searchText)
                            .textInputAutocapitalization(.never)
                    }
                    .padding(10)
                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))

                    CafeFilterChips(selection: $viewModel.selectedFilter)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
            }
            .sheet(item: $viewModel.selectedSpot) { spot in
                CafeDetailSheet(spot: spot, viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showAddSheet) {
                AddCafeSearchSheet(viewModel: viewModel) { item in
                    viewModel.addCafe(from: item, context: modelContext)
                }
            }
        }
    }
}

#Preview {
    CafeMapView()
        .modelContainer(PreviewData.container)
}
