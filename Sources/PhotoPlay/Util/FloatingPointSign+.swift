import CoreGraphics

extension FloatingPointSign {
    var multiplier: CGFloat {
        switch self {
        case .plus:
            return 1
        case .minus:
            return -1
        }
    }
}
