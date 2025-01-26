import Foundation

public class PinchGestureMappedEmpty: CanvasPinchGestureMappable {
    public init() {}
    public func began(_ position: CGPoint) {}
    public func pinch(_ scale: CGFloat) {}
    public func end() {}
}
