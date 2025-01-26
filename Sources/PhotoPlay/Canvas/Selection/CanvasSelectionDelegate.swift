import QuartzCore

protocol CanvasSelectionDelegate: AnyObject {
    func select(for layer: CALayer)
    func deselectAll()
}
