import SwiftUI

struct CafeFilterChips: View {
    @Binding var selection: CafeMapFilter

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(CafeMapFilter.allCases) { filter in
                    Button {
                        selection = filter
                    } label: {
                        Text(filter.title)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selection == filter ? Color.accentColor : Color(.systemGray5), in: Capsule())
                            .foregroundStyle(selection == filter ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var filter = CafeMapFilter.all
    CafeFilterChips(selection: $filter)
        .padding()
}
