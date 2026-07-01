import Foundation

struct BrewStep: Codable, Identifiable {
    var id: Int { order }
    let order: Int
    let label: String
    let waterAmount: Int?
    let durationSec: Int
    let instruction: String
}
