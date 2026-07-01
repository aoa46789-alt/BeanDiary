import SwiftUI

struct CafeMapPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "카페 지도",
                systemImage: "map",
                description: Text("Phase 4a에서 콜롬버스 가이드·드립 전문 카페 지도가 추가됩니다.")
            )
            .navigationTitle("지도")
        }
    }
}

#Preview {
    CafeMapPlaceholderView()
}
