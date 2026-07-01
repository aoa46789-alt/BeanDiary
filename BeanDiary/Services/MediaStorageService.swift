import AVFoundation
import Foundation
import Photos
import UIKit
import UniformTypeIdentifiers

struct PendingMediaItem: Identifiable {
    let id = UUID()
    var mediaType: MediaType
    var fileName: String
    var thumbnailFileName: String?
    var capturedAt: Date
    var durationSec: Double?
}

enum MediaStorageService {
    static let mediaDirectoryName = "Media"
    static let maxAttachmentsPerLog = 10

    static var mediaDirectoryURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let media = documents.appendingPathComponent(mediaDirectoryName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: media.path) {
            try? FileManager.default.createDirectory(at: media, withIntermediateDirectories: true)
        }
        return media
    }

    static func fileURL(for fileName: String) -> URL {
        mediaDirectoryURL.appendingPathComponent(fileName)
    }

    static func savePhotoData(_ data: Data, capturedAt: Date) throws -> PendingMediaItem {
        let fileName = "\(UUID().uuidString).jpg"
        let url = fileURL(for: fileName)
        try data.write(to: url, options: .atomic)
        return PendingMediaItem(
            mediaType: .photo,
            fileName: fileName,
            thumbnailFileName: nil,
            capturedAt: capturedAt,
            durationSec: nil
        )
    }

    static func importVideo(from sourceURL: URL, capturedAt: Date) throws -> PendingMediaItem {
        let fileName = "\(UUID().uuidString).mp4"
        let destination = fileURL(for: fileName)
        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }
        try FileManager.default.copyItem(at: sourceURL, to: destination)

        let asset = AVURLAsset(url: destination)
        let duration = CMTimeGetSeconds(asset.duration)
        let thumbName = try generateVideoThumbnail(for: destination)

        return PendingMediaItem(
            mediaType: .video,
            fileName: fileName,
            thumbnailFileName: thumbName,
            capturedAt: capturedAt,
            durationSec: duration.isFinite ? duration : nil
        )
    }

    static func generateVideoThumbnail(for videoURL: URL) throws -> String {
        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 0.5, preferredTimescale: 600)
        let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
        let image = UIImage(cgImage: cgImage)
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw MediaStorageError.thumbnailFailed
        }
        let thumbName = "\(UUID().uuidString)_thumb.jpg"
        try data.write(to: fileURL(for: thumbName), options: .atomic)
        return thumbName
    }

    static func deleteFiles(for attachment: DiaryAttachment) {
        let mediaURL = fileURL(for: attachment.fileName)
        try? FileManager.default.removeItem(at: mediaURL)
        if let thumb = attachment.thumbnailFileName {
            try? FileManager.default.removeItem(at: fileURL(for: thumb))
        }
    }

    static func loadImage(fileName: String) -> UIImage? {
        let url = fileURL(for: fileName)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    static func formattedDuration(_ seconds: Double?) -> String {
        guard let seconds, seconds.isFinite, seconds > 0 else { return "0:00" }
        let total = Int(seconds.rounded())
        let minutes = total / 60
        let secs = total % 60
        return String(format: "%d:%02d", minutes, secs)
    }

    static func totalStorageBytes() -> Int64 {
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: mediaDirectoryURL,
            includingPropertiesForKeys: [.fileSizeKey]
        ) else { return 0 }
        return files.reduce(0) { partial, url in
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            return partial + Int64(size)
        }
    }
}

enum MediaStorageError: LocalizedError {
    case thumbnailFailed
    case importFailed

    var errorDescription: String? {
        switch self {
        case .thumbnailFailed: return "영상 썸네일을 만들지 못했습니다."
        case .importFailed: return "미디어를 가져오지 못했습니다."
        }
    }
}
