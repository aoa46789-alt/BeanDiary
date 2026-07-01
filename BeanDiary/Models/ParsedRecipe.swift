import Foundation
import SwiftData

@Model
final class ParsedRecipe {
    var beanName: String
    var sourceType: String
    var sourceVideoId: String?
    var coffeeGrams: Double
    var waterGrams: Double?
    var ratio: String?
    var waterTemp: Int?
    var dripper: String?
    var brewMethod: String?
    var totalBrewTimeSec: Int?
    var sourceGrinder: String?
    var sourceGrindSetting: String?
    var convertedGrinder: String
    var convertedGrindClicks: Int?
    var grindConversionNote: String?
    var stepsJSON: String
    var fetchedAt: Date

    @Relationship(deleteRule: .nullify, inverse: \CoffeeLog.usedRecipe)
    var coffeeLogs: [CoffeeLog]

    init(
        beanName: String,
        sourceType: String = "manual",
        sourceVideoId: String? = nil,
        coffeeGrams: Double = 15,
        waterGrams: Double? = nil,
        ratio: String? = nil,
        waterTemp: Int? = nil,
        dripper: String? = nil,
        brewMethod: String? = nil,
        totalBrewTimeSec: Int? = nil,
        sourceGrinder: String? = nil,
        sourceGrindSetting: String? = nil,
        convertedGrinder: String = "Comandante C40",
        convertedGrindClicks: Int? = nil,
        grindConversionNote: String? = nil,
        stepsJSON: String = "[]",
        fetchedAt: Date = .now
    ) {
        self.beanName = beanName
        self.sourceType = sourceType
        self.sourceVideoId = sourceVideoId
        self.coffeeGrams = coffeeGrams
        self.waterGrams = waterGrams
        self.ratio = ratio
        self.waterTemp = waterTemp
        self.dripper = dripper
        self.brewMethod = brewMethod
        self.totalBrewTimeSec = totalBrewTimeSec
        self.sourceGrinder = sourceGrinder
        self.sourceGrindSetting = sourceGrindSetting
        self.convertedGrinder = convertedGrinder
        self.convertedGrindClicks = convertedGrindClicks
        self.grindConversionNote = grindConversionNote
        self.stepsJSON = stepsJSON
        self.fetchedAt = fetchedAt
        self.coffeeLogs = []
    }
}
