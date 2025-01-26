import QuartzCore

class PinchGestureMappedOverlayTransform: CanvasPinchGestureMappable {
    private var context: PinchGestureContext?

    weak var hitDetector: (any CanvasHitDetecter)!
    weak var selectionDelegate: (any CanvasSelectionDelegate)!
    weak var delegate: (any PinchGestureMappedTransformDelegate)!

    func began(_ position: CGPoint) {
        guard let hitLayer = hitDetector.hitTransformable(at: position) as? CAParentRelativeLayer else { return }
        selectionDelegate.select(for: hitLayer)

        context = .relativeLayer(target: hitLayer, fromScale: hitLayer.relativeScale, gestureScale: 1)
    }

    func pinch(_ scale: CGFloat) {
        guard let context else { return }

        switch context {
        case let .relativeLayer(target, fromScale, transformScale):
            self.context = .relativeLayer(
                target: target,
                fromScale: fromScale,
                gestureScale: scale
            )
        }
        delegate.pinch(self.context!)
    }

    func end() {
        context = nil
    }
}
