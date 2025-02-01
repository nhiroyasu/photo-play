import QuartzCore

extension CAImageCanvasManager: PanGestureMappedTransformDelegate {
    func pan(_ context: TranslationContext) {
        switch context {
        case .relativeLayer(let target, let fromRelativePoint, let gestureTranslation):
            let transformedPosition = transformPoint(
                gestureTranslation,
                with: CATransform3DInvert(removeTranslation(for: self.transform))
            )
            target.relativePoint = CGPoint(
                x: fromRelativePoint.x + transformedPosition.x / baseImageFrame.width,
                y: fromRelativePoint.y + transformedPosition.y / baseImageFrame.height
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
