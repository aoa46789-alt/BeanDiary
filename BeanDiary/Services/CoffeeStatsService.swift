import Foundation
import SwiftData

struct CoffeeStats {
    let lastDrankAt: Date?
    let daysSinceLast: Int?
    let weeklyCount: Int
    let monthlyCount: Int
}

enum CoffeeStatsService {
    static func compute(from logs: [CoffeeLog], now: Date = .now) -> CoffeeStats {
        let sorted = logs.sorted { $0.drankAt > $1.drankAt }
        let lastDrankAt = sorted.first?.drankAt

        let daysSinceLast: Int? = lastDrankAt.map { last in
            let start = Calendar.current.startOfDay(for: last)
            let today = Calendar.current.startOfDay(for: now)
            return Calendar.current.dateComponents([.day], from: start, to: today).day ?? 0
        }

        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
        let monthAgo = Calendar.current.date(byAdding: .day, value: -30, to: now) ?? now

        let weeklyCount = logs.filter { $0.drankAt >= weekAgo }.count
        let monthlyCount = logs.filter { $0.drankAt >= monthAgo }.count

        return CoffeeStats(
            lastDrankAt: lastDrankAt,
            daysSinceLast: daysSinceLast,
            weeklyCount: weeklyCount,
            monthlyCount: monthlyCount
        )
    }

    static func daysSinceText(_ days: Int?) -> String {
        guard let days else { return "기록 없음" }
        if days == 0 { return "오늘" }
        if days == 1 { return "1일 전" }
        return "\(days)일 전"
    }
}

enum BeanService {
    static func findOrCreate(name: String, in context: ModelContext) -> CoffeeBean {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let descriptor = FetchDescriptor<CoffeeBean>(
            predicate: #Predicate { $0.name == trimmed }
        )
        if let existing = try? context.fetch(descriptor).first {
            return existing
        }
        let bean = CoffeeBean(name: trimmed)
        context.insert(bean)
        return bean
    }
}
