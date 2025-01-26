import Foundation

public protocol CanvasPanGestureMappable {
    func began(_ position: CGPoint)
    func move(_ translation: CGPoint)
    func end()
}
