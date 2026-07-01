import Foundation

struct CafePreview: Codable {
    let highlights: [String]
    let characteristics: String
    let tasteSummary: String
    let reviewSentiment: String
    let reviewSummary: String
    let recommendedMenu: String?
    let dripSpecialtyNote: String?
    let columbusNote: String?
    let isDripSpecialty: Bool?
}
