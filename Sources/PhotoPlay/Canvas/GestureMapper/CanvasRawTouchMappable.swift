import Foundation

public protocol CanvasRawTouchMappable {
    /// Began the touch to the operation.
    /// - Parameter point: This point must be in the workspace layer's coordinate system
    func began(_ point: CGPoint)
    /// Moves the touch to the operation.
    /// - Parameter point: This point must be in the workspace layer's coordinate system
    func move(_ point: CGPoint)
    func end()
    func cancel()
}
