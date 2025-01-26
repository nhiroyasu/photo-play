import QuartzCore

class RotationGestureMappedOverlayTransform: CanvasRotationGestureMappable {
    private var context: RotationGestureContext?

    weak var hitDetecter: (any CanvasHitDetecter)!
    weak var selectionDelegate: (any CanvasSelectionDelegate)!
    weak var delegate: (any RotationGestureMappedTransformDelegate)!

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
