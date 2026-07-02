import SwiftUI

struct OfflineBanner: View {
    @State private var connectivity = ConnectivityMonitor.shared

    var body: some View {
        if !connectivity.isOnline {
            HStack(spacing: 8) {
                Image(systemName: "wifi.slash")
                Text("오프라인 — 저장된 데이터만 사용할 수 있습니다")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.15))
            .foregroundStyle(.orange)
        }
    }
}
