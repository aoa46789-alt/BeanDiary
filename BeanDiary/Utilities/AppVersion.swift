import Foundation

enum AppVersion {
    static var marketing: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    static var full: String {
        "\(marketing) (\(build))"
    }

    static var privacyPolicyURL: URL {
        URL(string: "https://github.com/aoa46789-alt/BeanDiary/blob/main/PRIVACY_POLICY.md")!
    }
}
