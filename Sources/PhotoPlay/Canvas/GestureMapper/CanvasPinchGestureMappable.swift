import Foundation

public protocol CanvasPinchGestureMappable {
    func began(_ position: CGPoint)
    func pinch(_ scale: CGFloat)
    func end()
}
