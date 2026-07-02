import Network

@MainActor
@Observable
final class ConnectivityMonitor {
    static let shared = ConnectivityMonitor()

    private(set) var isOnline = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.beandiary.connectivity")

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isOnline = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}
