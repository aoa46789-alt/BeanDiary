import Foundation
import SwiftData

@Model
final class CoffeeLog {
    var drankAt: Date
    var brewMethod: String
    var rating: Int?
    var grindSize: String?
    var waterTemp: Int?
    var ratio: String?

    var tastingNote: String?
    var flavorTagsJSON: String?
    var tastedAcidity: Int?
    var tastedBody: Int?
    var tastedSweetness: Int?
    var tastedBitterness: Int?

    var bean: CoffeeBean?
    var cafeSpot: CafeSpot?
    var usedRecipe: ParsedRecipe?

    @Relationship(deleteRule: .cascade, inverse: \DiaryAttachment.coffeeLog)
    var attachments: [DiaryAttachment]

    init(
        drankAt: Date = .now,
        brewMethod: String = BrewMethod.handDrip.rawValue,
        rating: Int? = nil,
        grindSize: String? = nil,
        waterTemp: Int? = nil,
        ratio: String? = nil,
        tastingNote: String? = nil,
        flavorTagsJSON: String? = nil,
        tastedAcidity: Int? = nil,
        tastedBody: Int? = nil,
        tastedSweetness: Int? = nil,
        tastedBitterness: Int? = nil,
        bean: CoffeeBean? = nil,
        cafeSpot: CafeSpot? = nil,
        usedRecipe: ParsedRecipe? = nil
    ) {
        self.drankAt = drankAt
        self.brewMethod = brewMethod
        self.rating = rating
        self.grindSize = grindSize
        self.waterTemp = waterTemp
        self.ratio = ratio
        self.tastingNote = tastingNote
        self.flavorTagsJSON = flavorTagsJSON
        self.tastedAcidity = tastedAcidity
        self.tastedBody = tastedBody
        self.tastedSweetness = tastedSweetness
        self.tastedBitterness = tastedBitterness
        self.bean = bean
        self.cafeSpot = cafeSpot
        self.usedRecipe = usedRecipe
        self.attachments = []
    }
}

enum BrewMethod: String, CaseIterable, Identifiable {
    case handDrip = "핸드드립"
    case espresso = "에스프레소"
    case frenchPress = "프렌치프레스"
    case aeropress = "에어로프레스"
    case moka = "모카포트"
    case other = "기타"

    var id: String { rawValue }
}
