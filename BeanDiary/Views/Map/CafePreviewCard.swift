import SwiftUI

struct CafePreviewCard: View {
    let preview: CafePreview
    let fetchedAt: Date?
    let isEstimated: Bool

    init(preview: CafePreview, fetchedAt: Date? = nil, isEstimated: Bool = false) {
        self.preview = preview
        self.fetchedAt = fetchedAt
        self.isEstimated = preview.reviewSentiment.contains("추정") || isEstimated
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            if !preview.highlights.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(preview.highlights, id: \.self) { highlight in
                        Text(highlight)
                            .font(.caption2.weight(.medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.12), in: Capsule())
                    }
                }
            }

            if !preview.characteristics.isEmpty {
                Label(preview.characteristics, systemImage: "building.2")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("맛 요약")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(preview.tasteSummary)
                    .font(.body)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("리뷰 요약")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(preview.reviewSummary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            specialtyNotes

            if let menu = preview.recommendedMenu, !menu.isEmpty {
                LabeledContent("추천 메뉴", value: menu)
                    .font(.caption)
            }

            if let fetchedAt {
                Text("캐시됨 · \(DateFormatting.fullFormatter.string(from: fetchedAt))")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    private var header: some View {
        HStack {
            Label("카페 미리보기", systemImage: "sparkles")
                .font(.subheadline.weight(.semibold))
            Spacer()
            sentimentBadge
        }
    }

    @ViewBuilder
    private var sentimentBadge: some View {
        if isEstimated {
            badge("AI 추정", .orange)
        } else {
            badge(preview.reviewSentiment, sentimentColor)
        }
    }

    @ViewBuilder
    private var specialtyNotes: some View {
        if let note = preview.dripSpecialtyNote, !note.isEmpty {
            noteRow("드립 전문", note, .orange, "drop.fill")
        }
        if let note = preview.columbusNote, !note.isEmpty {
            noteRow("콜럼버스", note, .purple, "star.fill")
        }
    }

    private func noteRow(_ title: String, _ text: String, _ color: Color, _ icon: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }

    private func badge(_ text: String, _ color: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15), in: Capsule())
            .foregroundStyle(color)
    }

    private var sentimentColor: Color {
        let sentiment = preview.reviewSentiment.lowercased()
        if sentiment.contains("긍정") { return .green }
        if sentiment.contains("부정") { return .red }
        return .secondary
    }
}

/// 간단한 태그 줄바꿈 레이아웃
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var frames: [CGRect] = []

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), frames)
    }
}

#Preview {
    CafePreviewCard(
        preview: CafePreview(
            highlights: ["조용한 공간", "싱글 오리진"],
            characteristics: "미니멀 인테리어, 창가 좌석",
            tasteSummary: "밝은 산미의 드립이 특징입니다.",
            reviewSentiment: "긍정",
            reviewSummary: "스페셜티 드립 전문점으로 평가됩니다.",
            recommendedMenu: "에티오피아 핸드드립",
            dripSpecialtyNote: "드립 바 테이블 4석",
            columbusNote: "2024 콜럼버스 가이드 선정",
            isDripSpecialty: true
        ),
        fetchedAt: .now
    )
    .padding()
}
