import SwiftUI

struct YouTubeVideoRow: View {
    let video: YouTubeVideo
    let isParsing: Bool
    let onPlay: () -> Void
    let onParse: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            thumbnail
                .frame(width: 120, height: 68)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 6) {
                Text(video.title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(2)
                Text(video.channelTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    Button(action: onPlay) {
                        Label("재생", systemImage: "play.fill")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)

                    Button(action: onParse) {
                        if isParsing {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Label("레시피 분석", systemImage: "text.magnifyingglass")
                                .font(.caption)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    .disabled(isParsing)
                }
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let url = video.thumbnailURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    placeholder
                }
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        Color.gray.opacity(0.2)
            .overlay {
                Image(systemName: "play.rectangle.fill")
                    .foregroundStyle(.secondary)
            }
    }
}

#Preview {
    YouTubeVideoRow(
        video: .preview,
        isParsing: false,
        onPlay: {},
        onParse: {}
    )
    .padding()
}
