import MapKit
import SwiftUI

struct AddCafeSearchSheet: View {
    @Bindable var viewModel: CafeMapViewModel
    let onAdd: (MKMapItem) -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("카페명, 지역 검색", text: $viewModel.addSearchText)
                        .textInputAutocapitalization(.never)
                    Toggle("콜럼버스 가이드 선정", isOn: $viewModel.addColumbusGuide)
                    Button("검색") {
                        Task { await viewModel.searchToAdd() }
                    }
                    .disabled(viewModel.addSearchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isAddSearching)
                }

                if viewModel.isAddSearching {
                    ProgressView()
                }

                ForEach(Array(viewModel.addSearchResults.enumerated()), id: \.offset) { _, item in
                    Button {
                        onAdd(item)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name ?? "카페")
                                .font(.headline)
                            if let address = item.placemark.title {
                                Text(address)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("카페 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { viewModel.showAddSheet = false }
                }
            }
        }
    }
}
