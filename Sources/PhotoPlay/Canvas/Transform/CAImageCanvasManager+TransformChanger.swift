import QuartzCore

extension CAImageCanvasManager: CanvasTransformChanger {
    func onChange(to transform: CATransform3D, immediate: Bool) {
        self.transform = transform
        CATransaction.begin()
        CATransaction.setDisableActions(immediate)
        canvas.setNeedsLayout()
        canvas.layoutIfNeeded()
        CATransaction.commit()
    }
}
