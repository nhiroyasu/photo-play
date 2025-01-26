import QuartzCore

class PinchGestureMappedCrop: CanvasPinchGestureMappable {
    private let currentTransform: CATransform3D
    private let canvasBounds: CGRect
    private let baseImageFrame: CGRect

    weak var outBoundsMaskSwitcher: OutBoundsMaskSwitcher?
    weak var transformChanger: CanvasTransformChanger?

    private var context: CropContext?

    init(
        currentTransform: CATransform3D,
        canvasBounds: CGRect,
        baseImageFrame: CGRect
    ) {
        self.currentTransform = currentTransform
        self.canvasBounds = canvasBounds
        self.baseImageFrame = baseImageFrame
    }

    func began(_ position: CGPoint) {
        outBoundsMaskSwitcher?.on()

        context = CropContext.transform(
            fromTransform: currentTransform,
            concatTransform: currentTransform
        )
    }

    func pinch(_ scale: CGFloat) {
        guard let context else { return }

        switch context {
        case .transform(let fromTransform, let concatTransform):
            let newTransform = CATransform3DConcat(
                fromTransform,
                CATransform3DMakeScale(scale, scale, 1)
            )
            self.context = .transform(
                fromTransform: fromTransform,
                concatTransform: newTransform
            )
            transformChanger?.onChange(to: newTransform, immediate: true)

        case .crop:
            break
        }
    }

    func end() {
        guard let context else { return }

        let concatTransform: CATransform3D
        switch context {
        case .transform(_, let concatTransform):
            let targetFrame = baseImageFrame
            let canvasFrameOnTargetCoord = canvasBounds.transform(
                with: CATransform3DInvert(concatTransform),
                coordinate: CGPoint(x: canvasBounds.midX, y: canvasBounds.midY)
            )
            let fillTransform = fillTransformIfOutBounds(canvasFrameOnTargetCoord, in: targetFrame)
            let newTransform = CATransform3DConcat(concatTransform, fillTransform)

            transformChanger?.onChange(to: newTransform, immediate: false)
            outBoundsMaskSwitcher?.off()

            self.context = nil

        case .crop:
            break
        }
    }
}
