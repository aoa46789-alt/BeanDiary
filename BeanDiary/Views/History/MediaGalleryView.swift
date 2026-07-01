import SwiftData
import SwiftUI

struct MediaGalleryView: View {
    let attachments: [DiaryAttachment]
    @State private var selectedPhoto: DiaryAttachment?
    @State private var selectedVideo: DiaryAttachment?

    private var sortedAttachments: [DiaryAttachment] {
        attachments.sorted { $0.capturedAt < $1.capturedAt }
    }

    var body: some View {
        if sortedAttachments.isEmpty {
            EmptyView()
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(sortedAttachments) { attachment in
                        Button {
                            if attachment.type == .photo {
                                selectedPhoto = attachment
                            } else {
                                selectedVideo = attachment
                            }
                        } label: {
                            MediaThumbnailView(attachment: attachment)
                                .frame(width: 72, height: 72)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .fullScreenCover(isPresented: Binding(
                get: { selectedPhoto != nil },
                set: { if !$0 { selectedPhoto = nil } }
            )) {
                if let attachment = selectedPhoto {
                    PhotoViewerView(attachment: attachment)
                }
            }
            .sheet(isPresented: Binding(
                get: { selectedVideo != nil },
                set: { if !$0 { selectedVideo = nil } }
            )) {
                if let attachment = selectedVideo {
                    VideoPlayerScreen(attachment: attachment)
                }
            }
        }
    }
}

struct MediaThumbnailView: View {
    let attachment: DiaryAttachment

    var body: some View {
        Group {
            if attachment.type == .photo,
               let image = MediaStorageService.loadImage(fileName: attachment.fileName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if let thumb = attachment.thumbnailFileName,
                      let image = MediaStorageService.loadImage(fileName: thumb) {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                    Image(systemName: "play.fill")
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(.black.opacity(0.45), in: Circle())
                }
            } else {
                Color.gray.opacity(0.2)
                    .overlay {
                        Image(systemName: attachment.type == .video ? "video" : "photo")
                    }
            }
        }
    }
}
