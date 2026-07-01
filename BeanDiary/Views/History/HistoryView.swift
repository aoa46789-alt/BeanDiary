import SwiftData
import SwiftUI

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CoffeeLog.drankAt, order: .reverse) private var logs: [CoffeeLog]

    @State private var brewFilter: BrewMethod?
    @State private var beanFilter = ""

    private var filteredLogs: [CoffeeLog] {
        logs.filter { log in
            let brewOK = brewFilter.map { $0.rawValue == log.brewMethod } ?? true
            let beanOK = beanFilter.isEmpty ||
                (log.bean?.name.localizedCaseInsensitiveContains(beanFilter) ?? false)
            return brewOK && beanOK
        }
    }

    private var groupedLogs: [(day: Date, logs: [CoffeeLog])] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: filteredLogs) { log -> Date in
            let reference = log.attachments.map(\.capturedAt).max() ?? log.drankAt
            return calendar.startOfDay(for: reference)
        }
        return groups
            .map { (day: $0.key, logs: $0.value.sorted { lhs, rhs in
                let l = lhs.attachments.map(\.capturedAt).max() ?? lhs.drankAt
                let r = rhs.attachments.map(\.capturedAt).max() ?? rhs.drankAt
                return l > r
            }) }
            .sorted { $0.day > $1.day }
    }

    var body: some View {
        List {
            Section {
                TextField("원두 이름 필터", text: $beanFilter)
                Picker("추출 방식", selection: $brewFilter) {
                    Text("전체").tag(nil as BrewMethod?)
                    ForEach(BrewMethod.allCases) { method in
                        Text(method.rawValue).tag(Optional(method))
                    }
                }
            }

            if groupedLogs.isEmpty {
                ContentUnavailableView(
                    "기록이 없습니다",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("커피를 마시고 기록을 남겨보세요.")
                )
            } else {
                ForEach(groupedLogs, id: \.day.timeIntervalSince1970) { group in
                    Section(DateFormatting.dayHeaderFormatter.string(from: group.day)) {
                        ForEach(group.logs) { log in
                            TimelineEntryRow(log: log)
                        }
                        .onDelete { offsets in
                            deleteLogs(at: offsets, in: group.logs)
                        }
                    }
                }
            }
        }
        .navigationTitle("기록 타임라인")
    }

    private func deleteLogs(at offsets: IndexSet, in sectionLogs: [CoffeeLog]) {
        for index in offsets {
            let log = sectionLogs[index]
            for attachment in log.attachments {
                MediaStorageService.deleteFiles(for: attachment)
            }
            modelContext.delete(log)
        }
        try? modelContext.save()
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
    .modelContainer(PreviewData.container)
}
