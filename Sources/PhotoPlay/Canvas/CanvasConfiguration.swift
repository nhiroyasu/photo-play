import Foundation

public struct CanvasConfiguration {
    let contentsScale: CGFloat

    public init(contentsScale: CGFloat) {
        self.contentsScale = contentsScale
    }
}

public extension CanvasConfiguration {
    static let `default` = CanvasConfiguration(
        contentsScale: 1
    )
}
