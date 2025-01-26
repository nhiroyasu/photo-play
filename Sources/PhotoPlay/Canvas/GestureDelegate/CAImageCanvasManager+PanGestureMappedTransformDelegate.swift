import QuartzCore

extension CAImageCanvasManager: PanGestureMappedTransformDelegate {
    func pan(_ context: TranslationContext) {
        switch context {
        case .relativeLayer(let target, let fromWorkspacePosition, let gestureTranslation):
            let nextWorkspacePosition = CGPoint(
                x: fromWorkspacePosition.x + gestureTranslation.x,
                y: fromWorkspacePosition.y + gestureTranslation.y
            )
            let convertedPosition = workspace.convert(nextWorkspacePosition, to: canvas)
            let transformedPosition = transformPoint(
                gestureTranslation,
                with: CATransform3DInvert(self.transform)
            )
            target.relativePoint = CGPoint(
                x: fromWorkspacePosition.x + transformedPosition.x / baseImageFrame.width,
                y: fromWorkspacePosition.y + transformedPosition.y / baseImageFrame.height
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
