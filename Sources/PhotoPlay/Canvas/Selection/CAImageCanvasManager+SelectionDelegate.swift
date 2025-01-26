import QuartzCore

extension CAImageCanvasManager: CanvasSelectionDelegate {
    func select(for layer: CALayer) {
        // NOTE: Now, we only support single selection.
        selectedLayers = [layer]
        selectionFrameLayer.setNeedsDisplay()
    }

    func deselectAll() {
        selectedLayers.removeAll()
        selectionFrameLayer.setNeedsDisplay()
    }
}
