import SwiftUI

struct CafePreviewCard: View {
    let preview: CafePreview
    let isEstimated: Bool

    init(preview: CafePreview, isEstimated: Bool = false) {
        self.preview = preview
        self.isEstimated = preview.reviewSentiment.contains("추정") || isEstimated
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("카페 미리보기", systemImage: "sparkles")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                if isEstimated {
                    Text("AI 추정")
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.orange.opacity(0.15), in: Capsule())
                        .foregroundStyle(.orange)
                }
            }

            if !preview.highlights.isEmpty {
                Text(preview.highlights.joined(separator: " · "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(preview.tasteSummary)
                .font(.body)

            Text(preview.reviewSummary)
                .font(.caption)
                .foregroundStyle(.secondary)

            if let menu = preview.recommendedMenu, !menu.isEmpty {
                LabeledContent("추천", value: menu)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    CafePreviewCard(preview: CafePreview(
        highlights: ["조용한 공간", "싱글 오리진"],
        characteristics: "미니멀 인테리어",
        tasteSummary: "밝은 산미의 드립이 특징입니다.",
        reviewSentiment: "긍정",
        reviewSummary: "스페셜티 드립 전문점으로 평가됩니다.",
        recommendedMenu: "핸드드립",
        dripSpecialtyNote: "드립 바 테이블",
        columbusNote: nil,
        isDripSpecialty: true
    ))
    .padding()
}
