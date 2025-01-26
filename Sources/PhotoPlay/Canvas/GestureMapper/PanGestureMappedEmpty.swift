import Foundation

public class PanGestureMappedEmpty: CanvasPanGestureMappable {
    public init() {}
    public func began(_ position: CGPoint) {}
    public func move(_ translation: CGPoint) {}
    public func end() {}
}
