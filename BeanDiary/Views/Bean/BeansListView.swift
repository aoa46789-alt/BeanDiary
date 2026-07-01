import SwiftData
import SwiftUI

struct BeansListView: View {
    @Query(sort: \CoffeeBean.createdAt, order: .reverse) private var beans: [CoffeeBean]

    var body: some View {
        NavigationStack {
            Group {
                if beans.isEmpty {
                    ContentUnavailableView(
                        "등록된 원두가 없어요",
                        systemImage: "leaf",
                        description: Text("커피 기록을 남기면 원두 목록이 채워집니다.")
                    )
                } else {
                    List(beans) { bean in
                        NavigationLink {
                            BeanDetailView(bean: bean)
                        } label: {
                            BeanRowView(bean: bean)
                        }
                    }
                }
            }
            .navigationTitle("원두")
        }
    }
}

private struct BeanRowView: View {
    let bean: CoffeeBean

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(bean.name)
                    .font(.headline)
                HStack(spacing: 8) {
                    Text("\(bean.logs.count)회 기록")
                    if let roaster = bean.roaster, !roaster.isEmpty {
                        Text("·")
                        Text(roaster)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Spacer()
            if bean.beanAnalysis != nil {
                Image(systemName: "sparkles")
                    .foregroundStyle(.orange)
                    .accessibilityLabel("AI 분석 완료")
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    BeansListView()
        .modelContainer(PreviewData.container)
}
