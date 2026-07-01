import SwiftUI
import SwiftData

@main
struct BeanDiaryApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [
            CoffeeBean.self,
            CoffeeLog.self,
            DiaryAttachment.self,
            ParsedRecipe.self,
            CafeSpot.self,
            UserGrinderSettings.self
        ])
    }
}
