import SwiftData
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("홈", systemImage: "house.fill")
                }

            CafeMapPlaceholderView()
                .tabItem {
                    Label("지도", systemImage: "map.fill")
                }

            LogCoffeeView()
                .tabItem {
                    Label("기록", systemImage: "plus.circle.fill")
                }

            BeansListPlaceholderView()
                .tabItem {
                    Label("원두", systemImage: "leaf.fill")
                }

            MoreView()
                .tabItem {
                    Label("더보기", systemImage: "ellipsis.circle.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(PreviewData.container)
}
