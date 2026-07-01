import Foundation

enum BrewMethod: String, CaseIterable, Identifiable, Hashable {
    case handDrip = "핸드드립"
    case espresso = "에스프레소"
    case frenchPress = "프렌치프레스"
    case aeropress = "에어로프레스"
    case moka = "모카포트"
    case other = "기타"

    var id: String { rawValue }
}
