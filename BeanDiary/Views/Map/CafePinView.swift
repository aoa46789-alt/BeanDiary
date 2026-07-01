import SwiftUI

struct CafePinView: View {
    let spot: CafeSpot

    var body: some View {
        ZStack {
            Circle()
                .fill(pinColor.gradient)
                .frame(width: 28, height: 28)
                .shadow(radius: 2)
            Image(systemName: pinIcon)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white)
        }
    }

    private var pinColor: Color {
        if spot.visitStatus == CafeVisitStatus.liked {
            return .green
        }
        if spot.visitStatus == CafeVisitStatus.wishlist {
            return .blue
        }
        if spot.isColumbusGuide {
            return .purple
        }
        if spot.isDripSpecialty == true {
            return .orange
        }
        return .brown
    }

    private var pinIcon: String {
        if spot.isColumbusGuide { return "star.fill" }
        if spot.isDripSpecialty == true { return "drop.fill" }
        return "cup.and.saucer.fill"
    }
}

#Preview {
    HStack {
        CafePinView(spot: PreviewData.sampleCafeSpot)
    }
}
