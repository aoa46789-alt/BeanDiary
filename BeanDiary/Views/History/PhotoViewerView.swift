import SwiftUI

struct PhotoViewerView: View {
    let attachment: DiaryAttachment
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                if let image = MediaStorageService.loadImage(fileName: attachment.fileName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    ContentUnavailableView("이미지를 불러올 수 없습니다", systemImage: "photo")
                }
            }
            .navigationTitle(DateFormatting.fullFormatter.string(from: attachment.capturedAt))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") { dismiss() }
                }
            }
        }
    }
}
