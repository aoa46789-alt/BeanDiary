import SwiftData
import SwiftUI

struct BeansListPlaceholderView: View {
    @Query(sort: \CoffeeBean.createdAt, order: .reverse) private var beans: [CoffeeBean]

    var body: some View {
        NavigationStack {
            Group {
                if beans.isEmpty {
                    ContentUnavailableView(
                        "등록된 원두가 없어요",
                        systemImage: "leaf",
                        description: Text("커피 기록을 남기면 원두 목록이 채워집니다.\nPhase 2에서 AI 분석이 추가됩니다.")
                    )
                } else {
                    List(beans) { bean in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(bean.name)
                                .font(.headline)
                            Text("\(bean.logs.count)회 기록")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("원두")
        }
    }
}

#Preview {
    BeansListPlaceholderView()
        .modelContainer(PreviewData.container)
}
