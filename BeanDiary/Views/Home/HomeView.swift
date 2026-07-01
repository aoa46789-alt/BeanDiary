import SwiftData
import SwiftUI

struct HomeView: View {
    @Query(sort: \CoffeeLog.drankAt, order: .reverse) private var logs: [CoffeeLog]

    private var stats: CoffeeStats {
        CoffeeStatsService.compute(from: logs)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("BeanDiary")
                        .font(.largeTitle.bold())

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCard(
                            title: "마지막 커피",
                            value: CoffeeStatsService.daysSinceText(stats.daysSinceLast),
                            icon: "clock.fill"
                        )
                        StatCard(
                            title: "이번 주",
                            value: "\(stats.weeklyCount)잔",
                            icon: "cup.and.saucer.fill"
                        )
                        StatCard(
                            title: "이번 달",
                            value: "\(stats.monthlyCount)잔",
                            icon: "calendar"
                        )
                        StatCard(
                            title: "전체 기록",
                            value: "\(logs.count)개",
                            icon: "list.bullet"
                        )
                    }

                    if let last = stats.lastDrankAt {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("최근 기록")
                                .font(.headline)
                            if let recent = logs.first {
                                RecentLogCard(log: recent)
                            }
                            Text("마지막 기록: \(DateFormatting.fullFormatter.string(from: last))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        ContentUnavailableView(
                            "아직 기록이 없어요",
                            systemImage: "cup.and.saucer",
                            description: Text("기록 탭에서 첫 커피를 남겨보세요.")
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    }
                }
                .padding()
            }
            .navigationTitle("홈")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct RecentLogCard: View {
    let log: CoffeeLog

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(log.bean?.name ?? "원두 미지정")
                    .font(.headline)
                Spacer()
                if let rating = log.rating {
                    Text(String(repeating: "★", count: rating))
                        .foregroundStyle(.yellow)
                        .font(.caption)
                }
            }
            Text("\(log.brewMethod) · \(DateFormatting.timeFormatter.string(from: log.drankAt))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let note = log.tastingNote, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HomeView()
        .modelContainer(PreviewData.container)
}
