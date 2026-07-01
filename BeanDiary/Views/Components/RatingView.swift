import SwiftUI

struct RatingView: View {
    @Binding var rating: Int
    var maxRating: Int = 5

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...maxRating, id: \.self) { index in
                Button {
                    rating = index
                } label: {
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .foregroundStyle(index <= rating ? .yellow : .gray.opacity(0.4))
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
        }
        .accessibilityLabel("평점 \(rating)점")
    }
}

#Preview {
    @Previewable @State var rating = 3
    RatingView(rating: $rating)
}
