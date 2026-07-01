import SwiftUI

struct CafeListView: View {
    let spots: [CafeSpot]
    let onSelect: (CafeSpot) -> Void

    var body: some View {
        List(spots, id: \.persistentModelID) { spot in
            Button {
                onSelect(spot)
            } label: {
                HStack(spacing: 12) {
                    CafePinView(spot: spot)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(spot.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        if let address = spot.address {
                            Text(address)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        HStack(spacing: 6) {
                            if spot.isColumbusGuide {
                                badge("콜럼버스", color: .purple)
                            }
                            if spot.isDripSpecialty == true {
                                badge("드립", color: .orange)
                            }
                            if spot.visitCount > 0 {
                                Text("\(spot.visitCount)회 방문")
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        if let preview = spot.cafePreview {
                            Text(preview.tasteSummary)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(.plain)
    }

    private func badge(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.15), in: Capsule())
            .foregroundStyle(color)
    }
}

#Preview {
    CafeListView(spots: [PreviewData.sampleCafeSpot], onSelect: { _ in })
}
