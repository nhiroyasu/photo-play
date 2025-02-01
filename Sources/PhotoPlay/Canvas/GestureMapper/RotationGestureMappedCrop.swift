import QuartzCore

class RotationGestureMappedCrop: CanvasRotationGestureMappable {
    private let fromTransform: CATransform3D
    private let canvasBounds: CGRect
    private let baseImageFrame: CGRect
    private unowned let outBoundsMaskSwitcher: OutBoundsMaskSwitcher
    private unowned let transformChanger: CanvasTransformChanger

    private var context: CropContext?
    private var resizeCropSize: CGSize?

    init(
        currentTransform fromTransform: CATransform3D,
        canvasBounds: CGRect,
        baseImageFrame: CGRect,
        outBoundsMaskSwitcher: OutBoundsMaskSwitcher,
        transformChanger: CanvasTransformChanger
    ) {
        self.fromTransform = fromTransform
        self.canvasBounds = canvasBounds
        self.baseImageFrame = baseImageFrame
        self.outBoundsMaskSwitcher = outBoundsMaskSwitcher
        self.transformChanger = transformChanger
    }

    func began(_ position: CGPoint) {
        outBoundsMaskSwitcher.on()

        context = CropContext.transform(
            fromTransform: fromTransform,
            concatTransform: fromTransform
        )
    }

    func rotate(_ rotation: CGFloat) {
        guard let context else { return }

        switch context {
        case let .transform(fromTransform, concatTransform):
            var newTransform = CATransform3DConcat(
                fromTransform,
                CATransform3DMakeRotation(rotation, 0, 0, 1)
            )
            let targetFrame = baseImageFrame
            let canvasFrameOnTargetCoord = canvasBounds.transform(
                with: CATransform3DInvert(newTransform),
                coordinate: CGPoint(x: canvasBounds.midX, y: canvasBounds.midY)
            )
            let fillTransform = fillTransformIfOutBounds(canvasFrameOnTargetCoord, in: targetFrame)
            newTransform = CATransform3DConcat(newTransform, fillTransform)

            self.context = .transform(
                fromTransform: fromTransform,
                concatTransform: newTransform
            )

            transformChanger.onChange(to: newTransform, immediate: true)

        case .crop: break
        }
    }

    func end() {
        outBoundsMaskSwitcher.off()
        context = nil
    }
}
