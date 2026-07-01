import AVKit
import SwiftUI

struct VideoPlayerScreen: View {
    let attachment: DiaryAttachment
    @Environment(\.dismiss) private var dismiss
    @State private var player: AVPlayer?

    var body: some View {
        NavigationStack {
            Group {
                if let player {
                    VideoPlayer(player: player)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle(DateFormatting.fullFormatter.string(from: attachment.capturedAt))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") { dismiss() }
                }
            }
            .onAppear {
                let url = MediaStorageService.fileURL(for: attachment.fileName)
                player = AVPlayer(url: url)
            }
            .onDisappear {
                player?.pause()
                player = nil
            }
        }
    }
}
