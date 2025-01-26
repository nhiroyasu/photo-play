import Foundation

public class RotationGestureMappedEmpty: CanvasRotationGestureMappable {
    public init() {}
    public func began(_ position: CGPoint) {}
    public func rotate(_ rotation: CGFloat) {}
    public func end() {}
}
