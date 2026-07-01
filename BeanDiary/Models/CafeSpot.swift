import Foundation
import SwiftData

@Model
final class CafeSpot {
    var name: String
    var address: String?
    var latitude: Double
    var longitude: Double
    var phone: String?
    var source: String
    var isColumbusGuide: Bool
    var isDripSpecialty: Bool?
    var isOnMap: Bool
    var visitStatus: String
    var hiddenReason: String?
    var visitCount: Int
    var lastVisitedAt: Date?
    var personalNote: String?
    var rating: Int?
    var createdAt: Date
    var previewJSON: String?
    var previewFetchedAt: Date?

    @Relationship(deleteRule: .nullify, inverse: \CoffeeLog.cafeSpot)
    var coffeeLogs: [CoffeeLog]

    init(
        name: String,
        address: String? = nil,
        latitude: Double = 0,
        longitude: Double = 0,
        phone: String? = nil,
        source: String = "manual",
        isColumbusGuide: Bool = false,
        isDripSpecialty: Bool? = nil,
        isOnMap: Bool = true,
        visitStatus: String = "unvisited",
        hiddenReason: String? = nil,
        visitCount: Int = 0,
        lastVisitedAt: Date? = nil,
        personalNote: String? = nil,
        rating: Int? = nil,
        createdAt: Date = .now,
        previewJSON: String? = nil,
        previewFetchedAt: Date? = nil
    ) {
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.phone = phone
        self.source = source
        self.isColumbusGuide = isColumbusGuide
        self.isDripSpecialty = isDripSpecialty
        self.isOnMap = isOnMap
        self.visitStatus = visitStatus
        self.hiddenReason = hiddenReason
        self.visitCount = visitCount
        self.lastVisitedAt = lastVisitedAt
        self.personalNote = personalNote
        self.rating = rating
        self.createdAt = createdAt
        self.previewJSON = previewJSON
        self.previewFetchedAt = previewFetchedAt
        self.coffeeLogs = []
    }
}
