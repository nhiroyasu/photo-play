import QuartzCore

class TapGestureMappedSelection: CanvasTapGestureMappable {
    weak var hitDetecter: (any CanvasHitDetecter)!
    weak var selectionDelegate: (any CanvasSelectionDelegate)!

    func tap(_ position: CGPoint) {
        if let hitLayer = hitDetecter.hitSelectable(at: position) {
            selectionDelegate.select(for: hitLayer)
        } else {
            selectionDelegate.deselectAll()
        }
    }
}
