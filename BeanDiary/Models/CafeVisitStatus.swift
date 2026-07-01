import Foundation

enum CafeVisitStatus {
    static let liked = "liked"
    static let wishlist = "wishlist"
    static let unvisited = "unvisited"
    static let neutral = "neutral"
    static let disliked = "disliked"

    static let displayNames: [String: String] = [
        liked: "좋아요",
        wishlist: "방문 예정",
        unvisited: "미방문",
        neutral: "중립",
        disliked: "숨김"
    ]
}

enum CafeHiddenReason {
    static let notTasty = "notTasty"
    static let notDripSpecialty = "notDripSpecialty"
}

enum CafeMapFilter: String, CaseIterable, Identifiable {
    case all
    case liked
    case wishlist
    case columbus
    case dripSpecialty
    case hidden

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "전체"
        case .liked: return "좋아요"
        case .wishlist: return "방문 예정"
        case .columbus: return "콜럼버스"
        case .dripSpecialty: return "드립 전문"
        case .hidden: return "숨긴 곳"
        }
    }

    func matches(_ spot: CafeSpot) -> Bool {
        switch self {
        case .all:
            return spot.isOnMap
        case .liked:
            return spot.isOnMap && spot.visitStatus == CafeVisitStatus.liked
        case .wishlist:
            return spot.isOnMap && spot.visitStatus == CafeVisitStatus.wishlist
        case .columbus:
            return spot.isOnMap && spot.isColumbusGuide
        case .dripSpecialty:
            return spot.isOnMap && (spot.isDripSpecialty == true)
        case .hidden:
            return !spot.isOnMap
        }
    }
}

extension CafeSpot {
    var cafePreview: CafePreview? {
        guard let previewJSON else { return nil }
        guard let data = previewJSON.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(CafePreview.self, from: data)
    }

    func storePreview(_ preview: CafePreview) {
        guard let data = try? JSONEncoder().encode(preview),
              let json = String(data: data, encoding: .utf8) else { return }
        previewJSON = json
        previewFetchedAt = .now
    }
}
