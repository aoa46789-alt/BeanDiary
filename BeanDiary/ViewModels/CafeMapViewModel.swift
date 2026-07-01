import MapKit
import SwiftData
import SwiftUI

@MainActor
@Observable
final class CafeMapViewModel {
    var searchText = ""
    var selectedFilter: CafeMapFilter = .all
    var showListMode = false
    var selectedSpot: CafeSpot?
    var cameraPosition: MapCameraPosition = .region(CafeMapService.defaultRegion)

    var addSearchText = ""
    var addSearchResults: [MKMapItem] = []
    var isAddSearching = false
    var showAddSheet = false
    var addColumbusGuide = false

    var isLoadingPreview = false
    var previewError: String?

    func filteredSpots(from all: [CafeSpot]) -> [CafeSpot] {
        CafeMapService.filter(all, filter: selectedFilter, searchText: searchText)
    }

    func select(_ spot: CafeSpot) {
        selectedSpot = spot
        cameraPosition = .region(MKCoordinateRegion(
            center: spot.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        ))
    }

    func searchToAdd() async {
        let query = addSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }
        isAddSearching = true
        defer { isAddSearching = false }
        do {
            addSearchResults = try await CafeMapService.searchCafes(query: query)
        } catch {
            addSearchResults = []
        }
    }

    func addCafe(from item: MKMapItem, context: ModelContext) {
        let spot = CafeMapService.createSpot(from: item, isColumbusGuide: addColumbusGuide)
        context.insert(spot)
        try? context.save()
        selectedSpot = spot
        showAddSheet = false
        addSearchText = ""
        addSearchResults = []
        select(spot)
    }

    func fetchPreview(for spot: CafeSpot, context: ModelContext) async {
        if spot.cafePreview != nil { return }
        isLoadingPreview = true
        previewError = nil
        defer { isLoadingPreview = false }
        do {
            let preview = try await CafePreviewService.fetchPreview(for: spot)
            spot.storePreview(preview)
            if let isDrip = preview.isDripSpecialty {
                spot.isDripSpecialty = isDrip
            }
            try context.save()
        } catch {
            previewError = error.localizedDescription
        }
    }
}
