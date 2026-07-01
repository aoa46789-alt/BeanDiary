import Foundation
import SwiftData

@Model
final class UserGrinderSettings {
    var primaryGrinder: String
    var defaultClicks: Int?

    init(primaryGrinder: String = "Comandante C40", defaultClicks: Int? = nil) {
        self.primaryGrinder = primaryGrinder
        self.defaultClicks = defaultClicks
    }
}
