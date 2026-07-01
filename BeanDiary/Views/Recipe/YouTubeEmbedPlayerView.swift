import SwiftUI
import WebKit

struct YouTubeEmbedPlayerView: View {
    let video: YouTubeVideo
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            YouTubeWebView(videoId: video.videoId)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle(video.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("닫기") { dismiss() }
                    }
                }
        }
    }
}

private struct YouTubeWebView: UIViewRepresentable {
    let videoId: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>
            body { margin: 0; background: #000; }
            .wrap { position: relative; padding-bottom: 56.25%; height: 0; }
            iframe { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: 0; }
          </style>
        </head>
        <body>
          <div class="wrap">
            <iframe src="https://www.youtube.com/embed/\(videoId)?playsinline=1&rel=0"
                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                    allowfullscreen></iframe>
          </div>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: URL(string: "https://www.youtube.com"))
    }
}

#Preview {
    YouTubeEmbedPlayerView(video: .preview)
}
