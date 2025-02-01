import QuartzCore

class TapGestureMappedSelection: CanvasTapGestureMappable {
    private unowned let hitDetecter: any CanvasHitDetecter
    private unowned let selectionDelegate: any CanvasSelectionDelegate

    init(hitDetecter: any CanvasHitDetecter, selectionDelegate: any CanvasSelectionDelegate) {
        self.hitDetecter = hitDetecter
        self.selectionDelegate = selectionDelegate
    }

    func tap(_ position: CGPoint) {
        if let hitLayer = hitDetecter.hitSelectable(at: position) {
            selectionDelegate.select(for: hitLayer)
        } else {
            selectionDelegate.deselectAll()
        }
    }
}
