import Foundation

class RawTouchMappedEmpty: CanvasRawTouchMappable {
    func began(_ point: CGPoint) {}
    func move(_ point: CGPoint) {}
    func end() {}
    func cancel() {}
}
