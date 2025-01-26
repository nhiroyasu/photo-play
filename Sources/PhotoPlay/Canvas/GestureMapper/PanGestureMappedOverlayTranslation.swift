import QuartzCore

class PanGestureMappedOverlayTranslation: CanvasPanGestureMappable {
    private var context: TranslationContext?

    weak var hitDetector: (any CanvasHitDetecter)!
    weak var selectionDelegate: (any CanvasSelectionDelegate)!
    weak var delegate: (any PanGestureMappedTransformDelegate)!

    public func began(_ position: CGPoint) {
        guard let hitLayer = hitDetector.hitTransformable(at: position) as? CAParentRelativeLayer else { return }
        selectionDelegate.select(for: hitLayer)

        context = .relativeLayer(
            target: hitLayer,
            fromWorkspacePosition: hitLayer.relativePoint,
            gestureTranslation: .zero
        )
    }

    public func move(_ translation: CGPoint) {
        guard let context else { return }

        switch context {
        case .relativeLayer(let target, let fromWorkspacePosition, let gestureTranslation):
            self.context = .relativeLayer(
                target: target,
                fromWorkspacePosition: fromWorkspacePosition,
                gestureTranslation: CGPoint(
                    x: translation.x,
                    y: translation.y
                )
            )
            delegate.pan(context)
        }
    }

    public func end() {
        context = nil
    }
}
