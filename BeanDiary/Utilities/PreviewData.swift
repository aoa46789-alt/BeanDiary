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

        let cafe1 = CafeSpot(
            name: "테스트 스페셜티",
            address: "서울 종로구",
            latitude: 37.5700,
            longitude: 126.9820,
            isColumbusGuide: true,
            isDripSpecialty: true,
            isOnMap: true,
            visitStatus: CafeVisitStatus.unvisited
        )
        let cafe2 = CafeSpot(
            name: "좋아하는 카페",
            address: "서울 마포구",
            latitude: 37.5563,
            longitude: 126.9236,
            isOnMap: true,
            visitStatus: CafeVisitStatus.liked,
            visitCount: 3,
            lastVisitedAt: .now
        )
        container.mainContext.insert(cafe1)
        container.mainContext.insert(cafe2)

        return container
    }()

    static var sampleCafeSpot: CafeSpot {
        CafeSpot(
            name: "프리뷰 카페",
            address: "서울 중구",
            latitude: 37.5665,
            longitude: 126.9780,
            isColumbusGuide: true,
            isDripSpecialty: true,
            isOnMap: true,
            visitStatus: CafeVisitStatus.wishlist
        )
    }

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
