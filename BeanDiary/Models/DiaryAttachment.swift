import Foundation
import SwiftData

enum MediaType: String, Codable {
    case photo
    case video
}

@Model
final class DiaryAttachment {
    var mediaType: String
    var fileName: String
    var thumbnailFileName: String?
    var capturedAt: Date
    var addedAt: Date
    var caption: String?
    var durationSec: Double?

    var coffeeLog: CoffeeLog?

    init(
        mediaType: MediaType,
        fileName: String,
        thumbnailFileName: String? = nil,
        capturedAt: Date = .now,
        addedAt: Date = .now,
        caption: String? = nil,
        durationSec: Double? = nil,
        coffeeLog: CoffeeLog? = nil
    ) {
        self.mediaType = mediaType.rawValue
        self.fileName = fileName
        self.thumbnailFileName = thumbnailFileName
        self.capturedAt = capturedAt
        self.addedAt = addedAt
        self.caption = caption
        self.durationSec = durationSec
        self.coffeeLog = coffeeLog
    }

    var type: MediaType {
        MediaType(rawValue: mediaType) ?? .photo
    }
}
