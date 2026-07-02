import Foundation
import SwiftData

@MainActor
@Observable
final class BeanDetailViewModel {
    var analysis: BeanAnalysis?
    var isLoading = false
    var errorMessage: String?

    func loadCached(from bean: CoffeeBean) {
        analysis = bean.beanAnalysis
        errorMessage = nil
    }

    func analyze(bean: CoffeeBean, context: ModelContext, forceRefresh: Bool = false) async {
        if !forceRefresh, let cached = bean.beanAnalysis {
            analysis = cached
            return
        }

        guard GeminiConfiguration.isConfigured else {
            errorMessage = GeminiError.notConfigured.errorDescription
            return
        }

        guard ConnectivityMonitor.shared.isOnline else {
            errorMessage = "오프라인 상태입니다. 저장된 분석 결과만 확인할 수 있습니다."
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await GeminiService.shared.analyzeBean(
                name: bean.name,
                roaster: bean.roaster,
                origin: bean.origin,
                roastLevel: bean.roastLevel
            )
            bean.storeAnalysis(result)
            try context.save()
            analysis = result
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
