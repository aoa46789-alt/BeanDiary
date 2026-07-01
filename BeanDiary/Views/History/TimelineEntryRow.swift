import SwiftUI

struct TimelineEntryRow: View {
    let log: CoffeeLog

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(DateFormatting.timeFormatter.string(from: displayDate))
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .frame(width: 48, alignment: .leading)

                VStack(alignment: .leading, spacing: 4) {
                    Text(log.bean?.name ?? "원두 미지정")
                        .font(.headline)
                    Text(log.brewMethod)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let rating = log.rating {
                    Text(String(repeating: "★", count: rating))
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }
            }

            MediaGalleryView(attachments: log.attachments)

            if let note = log.tastingNote, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if displayDate != log.drankAt {
                Text("기록 시각: \(DateFormatting.timeFormatter.string(from: log.drankAt))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 6)
    }

    private var displayDate: Date {
        log.attachments.map(\.capturedAt).max() ?? log.drankAt
    }
}
