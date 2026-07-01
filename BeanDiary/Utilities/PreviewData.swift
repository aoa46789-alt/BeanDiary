import SwiftData
import SwiftUI

enum PreviewData {
    @MainActor
    static let container: ModelContainer = {
        let schema = Schema([
            CoffeeBean.self,
            CoffeeLog.self,
            DiaryAttachment.self,
            ParsedRecipe.self,
            CafeSpot.self,
            UserGrinderSettings.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: config)

        let bean = CoffeeBean(name: "에티오피아 예가체프")
        let log = CoffeeLog(drankAt: .now, brewMethod: BrewMethod.handDrip.rawValue, rating: 4, bean: bean)
        container.mainContext.insert(bean)
        container.mainContext.insert(log)

        return container
    }()

    static var sampleBean: CoffeeBean {
        let bean = CoffeeBean(
            name: "에티오피아 예가체프 G1",
            roaster: "OOO 로스터스",
            origin: "예가체프",
            roastLevel: "라이트"
        )
        #if DEBUG
        bean.storeAnalysis(.preview)
        #endif
        return bean
    }
}
