import QuartzCore

class RotationGestureMappedOverlayTransform: CanvasRotationGestureMappable {
    private var context: RotationGestureContext?

    private unowned let hitDetecter: any CanvasHitDetecter
    private unowned let selectionDelegate: any CanvasSelectionDelegate
    private unowned let delegate: any RotationGestureMappedTransformDelegate

    init(
        hitDetecter: any CanvasHitDetecter,
        selectionDelegate: any CanvasSelectionDelegate,
        delegate: any RotationGestureMappedTransformDelegate
    ) {
        self.hitDetecter = hitDetecter
        self.selectionDelegate = selectionDelegate
        self.delegate = delegate
    }

    func began(_ position: CGPoint) {
        guard let hitLayer = hitDetecter.hitTransformable(at: position) as? CAParentRelativeLayer else { return }
        selectionDelegate.select(for: hitLayer)

        context = .relativeLayer(
            target: hitLayer,
            fromRotation: hitLayer.relativeRotation,
            gestureRotation: 0
        )
    }

    func rotate(_ rotation: CGFloat) {
        guard let context else { return }

        switch context {
        case .relativeLayer(let target, let fromRotation, let gestureRotation):
            self.context = .relativeLayer(
                target: target,
                fromRotation: fromRotation,
                gestureRotation: rotation
            )
            delegate.rotate(self.context!)
        }
    }

    func end() {
        context = nil
    }
}
