import Foundation
import SwiftData

@Model
final class CoffeeBean {
    var name: String
    var roaster: String?
    var origin: String?
    var roastLevel: String?
    var analysisJSON: String?
    var analysisFetchedAt: Date?
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \CoffeeLog.bean)
    var logs: [CoffeeLog]

    init(
        name: String,
        roaster: String? = nil,
        origin: String? = nil,
        roastLevel: String? = nil,
        analysisJSON: String? = nil,
        analysisFetchedAt: Date? = nil,
        createdAt: Date = .now
    ) {
        self.name = name
        self.roaster = roaster
        self.origin = origin
        self.roastLevel = roastLevel
        self.analysisJSON = analysisJSON
        self.analysisFetchedAt = analysisFetchedAt
        self.createdAt = createdAt
        self.logs = []
    }
}
