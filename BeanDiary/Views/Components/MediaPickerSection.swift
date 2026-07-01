import Photos
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct MediaPickerSection: View {
    @Binding var pendingItems: [PendingMediaItem]
    @Binding var capturedAtOverrides: [UUID: Date]

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var isImporting = false
    @State private var importError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("사진 · 영상")
                    .font(.headline)
                Spacer()
                Text("\(pendingItems.count)/\(MediaStorageService.maxAttachmentsPerLog)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if !pendingItems.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(pendingItems) { item in
                            PendingMediaThumbnail(
                                item: item,
                                capturedAt: bindingForCapturedAt(item.id)
                            ) {
                                removeItem(item)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            PhotosPicker(
                selection: $selectedItems,
                maxSelectionCount: max(0, MediaStorageService.maxAttachmentsPerLog - pendingItems.count),
                matching: .any(of: [.images, .videos])
            ) {
                Label("앨범에서 추가", systemImage: "photo.on.rectangle.angled")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(pendingItems.count >= MediaStorageService.maxAttachmentsPerLog || isImporting)
            .onChange(of: selectedItems) { _, newItems in
                Task { await importPickerItems(newItems) }
            }

            if isImporting {
                ProgressView("미디어 가져오는 중…")
            }

            if let importError {
                Text(importError)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    private func bindingForCapturedAt(_ id: UUID) -> Binding<Date> {
        Binding(
            get: { capturedAtOverrides[id] ?? pendingItems.first(where: { $0.id == id })?.capturedAt ?? .now },
            set: { capturedAtOverrides[id] = $0 }
        )
    }

    private func removeItem(_ item: PendingMediaItem) {
        pendingItems.removeAll { $0.id == item.id }
        capturedAtOverrides[item.id] = nil
        try? FileManager.default.removeItem(at: MediaStorageService.fileURL(for: item.fileName))
        if let thumb = item.thumbnailFileName {
            try? FileManager.default.removeItem(at: MediaStorageService.fileURL(for: thumb))
        }
    }

    @MainActor
    private func importPickerItems(_ items: [PhotosPickerItem]) async {
        guard !items.isEmpty else { return }
        isImporting = true
        importError = nil
        defer {
            isImporting = false
            selectedItems = []
        }

        for item in items {
            if pendingItems.count >= MediaStorageService.maxAttachmentsPerLog { break }

            if item.supportedContentTypes.contains(where: { $0.conforms(to: .movie) }) {
                await importVideo(item)
            } else {
                await importPhoto(item)
            }
        }
    }

    @MainActor
    private func importPhoto(_ item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            let capturedAt = await extractCreationDate(from: item) ?? .now
            let pending = try MediaStorageService.savePhotoData(data, capturedAt: capturedAt)
            pendingItems.append(pending)
            capturedAtOverrides[pending.id] = capturedAt
        } catch {
            importError = error.localizedDescription
        }
    }

    @MainActor
    private func importVideo(_ item: PhotosPickerItem) async {
        do {
            guard let movie = try await item.loadTransferable(type: VideoTransfer.self) else { return }
            let capturedAt = await extractCreationDate(from: item) ?? .now
            let pending = try MediaStorageService.importVideo(from: movie.url, capturedAt: capturedAt)
            pendingItems.append(pending)
            capturedAtOverrides[pending.id] = capturedAt
        } catch {
            importError = error.localizedDescription
        }
    }

    private func extractCreationDate(from item: PhotosPickerItem) async -> Date? {
        if let assetID = item.itemIdentifier {
            let assets = PHAsset.fetchAssets(withLocalIdentifiers: [assetID], options: nil)
            return assets.firstObject?.creationDate
        }
        return nil
    }
}

private struct PendingMediaThumbnail: View {
    let item: PendingMediaItem
    @Binding var capturedAt: Date
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topTrailing) {
                thumbnail
                    .frame(width: 96, height: 96)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .black.opacity(0.6))
                }
                .offset(x: 6, y: -6)
            }

            DatePicker(
                "촬영 시각",
                selection: $capturedAt,
                displayedComponents: [.date, .hourAndMinute]
            )
            .labelsHidden()
            .font(.caption2)
        }
        .frame(width: 120)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if item.mediaType == .photo, let image = MediaStorageService.loadImage(fileName: item.fileName) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else if let thumb = item.thumbnailFileName,
                  let image = MediaStorageService.loadImage(fileName: thumb) {
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                Image(systemName: "play.circle.fill")
                    .font(.title)
                    .foregroundStyle(.white)
                    .shadow(radius: 4)
            }
        } else {
            Color.gray.opacity(0.2)
                .overlay {
                    Image(systemName: item.mediaType == .video ? "video.fill" : "photo.fill")
                        .foregroundStyle(.secondary)
                }
        }
    }
}

private struct VideoTransfer: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { video in
            SentTransferredFile(video.url)
        } importing: { received in
            let copy = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mp4")
            if FileManager.default.fileExists(atPath: copy.path) {
                try FileManager.default.removeItem(at: copy)
            }
            try FileManager.default.copyItem(at: received.file, to: copy)
            return VideoTransfer(url: copy)
        }
    }
}
