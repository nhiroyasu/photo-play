import QuartzCore

extension CAImageCanvasManager: RotationGestureMappedTransformDelegate {
    func rotate(_ context: RotationGestureContext) {
        switch context {
        case let .relativeLayer(target, fromRotation, gestureRotation):
            target.relativeRotation = fromRotation + gestureRotation

            CATransaction.begin()
            CATransaction.setDisableActions(true)
            canvas.setNeedsLayout()
            canvas.layoutIfNeeded()
            selectionFrameLayer.setNeedsDisplay()
            selectionFrameLayer.displayIfNeeded()
            CATransaction.commit()
        }
    }
}
