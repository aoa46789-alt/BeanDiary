import CoreLocation
import MapKit

extension CafeSpot {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var mapsURL: URL? {
        URL(string: "http://maps.apple.com/?daddr=\(latitude),\(longitude)&q=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name)")
    }

    var naverMapsURL: URL? {
        URL(string: "nmap://place?lat=\(latitude)&lng=\(longitude)&name=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name)&appname=BeanDiary")
    }
}

enum CafeMapService {
    static let defaultRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    )

    static func filter(_ spots: [CafeSpot], filter: CafeMapFilter, searchText: String) -> [CafeSpot] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return spots.filter { spot in
            guard filter.matches(spot) else { return false }
            guard !trimmed.isEmpty else { return true }
            let haystack = [spot.name, spot.address ?? ""].joined(separator: " ").lowercased()
            return haystack.contains(trimmed)
        }
    }

    static func searchCafes(query: String, region: MKCoordinateRegion = defaultRegion) async throws -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query.contains("카페") ? query : "\(query) 카페"
        request.region = region
        request.resultTypes = .pointOfInterest

        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        return response.mapItems
    }

    static func createSpot(from item: MKMapItem, isColumbusGuide: Bool = false) -> CafeSpot {
        let coordinate = item.placemark.coordinate
        return CafeSpot(
            name: item.name ?? "카페",
            address: formatAddress(item.placemark),
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            phone: item.phoneNumber,
            source: "search",
            isColumbusGuide: isColumbusGuide,
            isOnMap: true,
            visitStatus: isColumbusGuide ? CafeVisitStatus.unvisited : CafeVisitStatus.neutral
        )
    }

    static func markLiked(_ spot: CafeSpot) {
        spot.isOnMap = true
        spot.visitStatus = CafeVisitStatus.liked
        spot.hiddenReason = nil
        spot.visitCount += 1
        spot.lastVisitedAt = .now
    }

    static func markWishlist(_ spot: CafeSpot) {
        spot.isOnMap = true
        spot.visitStatus = CafeVisitStatus.wishlist
        spot.hiddenReason = nil
    }

    static func markHidden(_ spot: CafeSpot, reason: String) {
        spot.isOnMap = false
        spot.visitStatus = CafeVisitStatus.disliked
        spot.hiddenReason = reason
    }

    static func restoreToMap(_ spot: CafeSpot) {
        spot.isOnMap = true
        spot.visitStatus = CafeVisitStatus.neutral
        spot.hiddenReason = nil
    }

    private static func formatAddress(_ placemark: MKPlacemark) -> String? {
        [
            placemark.administrativeArea,
            placemark.locality,
            placemark.thoroughfare,
            placemark.subThoroughfare
        ]
        .compactMap { $0 }
        .joined(separator: " ")
        .nilIfEmpty
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
