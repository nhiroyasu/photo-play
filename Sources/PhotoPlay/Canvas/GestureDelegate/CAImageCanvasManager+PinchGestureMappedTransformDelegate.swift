import QuartzCore

extension CAImageCanvasManager: PinchGestureMappedTransformDelegate {
    func pinch(_ context: PinchGestureContext) {
        switch context {
        case let .relativeLayer(target, fromScale, gestureScale):
            target.relativeScale = CGSize(
                width: fromScale.width * gestureScale,
                height: fromScale.height * gestureScale
            )

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
