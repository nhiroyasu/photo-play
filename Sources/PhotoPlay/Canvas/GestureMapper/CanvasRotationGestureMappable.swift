import CoreGraphics

public protocol CanvasRotationGestureMappable {
    func began(_ position: CGPoint)
    func rotate(_ rotation: CGFloat)
    func end()
}
