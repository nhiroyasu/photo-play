import QuartzCore

class PanGestureMappedCrop: CanvasPanGestureMappable {
    private let fromTransform: CATransform3D
    private let croppingGuideLayerFrame: CGRect
    private let canvasBounds: CGRect
    private let baseImageFrame: CGRect

    weak var outBoundsMaskSwitcher: OutBoundsMaskSwitcher?
    weak var transformChanger: CanvasTransformChanger?
    weak var delegate: (PanGestureMappedCropDelegate)?

    private var context: CropContext?

    init(
        currentTransform fromTransform: CATransform3D,
        croppingGuideLayerFrame: CGRect,
        canvasBounds: CGRect,
        baseImageFrame: CGRect
    ) {
        self.fromTransform = fromTransform
        self.croppingGuideLayerFrame = croppingGuideLayerFrame
        self.canvasBounds = canvasBounds
        self.baseImageFrame = baseImageFrame
    }

    func began(_ position: CGPoint) {
        let extraSpace: CGFloat = 64
        let cropLayerLeftTopSpace = CGRect(
            x: croppingGuideLayerFrame.minX,
            y: croppingGuideLayerFrame.minY,
            width: extraSpace,
            height: extraSpace
        )
        let cropLayerLeftBottomSpace = CGRect(
            x: croppingGuideLayerFrame.minX,
            y: croppingGuideLayerFrame.maxY - extraSpace,
            width: extraSpace,
            height: extraSpace
        )
        let cropLayerRightTopSpace = CGRect(
            x: croppingGuideLayerFrame.maxX - extraSpace,
            y: croppingGuideLayerFrame.minY,
            width: extraSpace,
            height: extraSpace
        )
        let cropLayerRightBottomSpace = CGRect(
            x: croppingGuideLayerFrame.maxX - extraSpace,
            y: croppingGuideLayerFrame.maxY - extraSpace,
            width: extraSpace,
            height: extraSpace
        )
        var cropOrigin: CropContext.CropOrigin?
        if cropLayerLeftTopSpace.contains(position) {
            cropOrigin = .leftTop
        } else if cropLayerLeftBottomSpace.contains(position) {
            cropOrigin = .leftBottom
        } else if cropLayerRightTopSpace.contains(position) {
            cropOrigin = .rightTop
        } else if cropLayerRightBottomSpace.contains(position) {
            cropOrigin = .rightBottom
        }

        if let cropOrigin {
            context = CropContext.crop(
                origin: cropOrigin,
                fromCropFrame: croppingGuideLayerFrame,
                toCropFrame: croppingGuideLayerFrame
            )
            delegate?.beganCropping()
        } else {
            context = CropContext.transform(
                fromTransform: fromTransform,
                concatTransform: fromTransform
            )
            outBoundsMaskSwitcher?.on()
        }
    }

    func move(_ translation: CGPoint) {
        guard let context else { return }

        switch context {
        case let .transform(fromTransform, concatTransform):
            let newTransform = CATransform3DConcat(
                fromTransform,
                CATransform3DMakeTranslation(translation.x, translation.y, 0)
            )

            self.context = .transform(
                fromTransform: fromTransform,
                concatTransform: newTransform
            )

            transformChanger?.onChange(to: newTransform, immediate: true)

        case let .crop(cropOrigin, fromCropFrame, toCropFrame):
            var newCropFrame: CGRect
            switch cropOrigin {
            case .leftTop:
                newCropFrame = CGRect(
                    x: max(fromCropFrame.origin.x + translation.x, fromCropFrame.origin.x),
                    y: max(fromCropFrame.origin.y + translation.y, fromCropFrame.origin.y),
                    width: fromCropFrame.width - translation.x,
                    height: fromCropFrame.height - translation.y
                )
            case .leftBottom:
                newCropFrame = CGRect(
                    x: max(fromCropFrame.origin.x + translation.x, fromCropFrame.origin.x),
                    y: fromCropFrame.origin.y,
                    width: fromCropFrame.width - translation.x,
                    height: fromCropFrame.height + translation.y
                )
            case .rightTop:
                newCropFrame = CGRect(
                    x: fromCropFrame.origin.x,
                    y: max(fromCropFrame.origin.y + translation.y, fromCropFrame.origin.y),
                    width: fromCropFrame.width + translation.x,
                    height: fromCropFrame.height - translation.y
                )
            case .rightBottom:
                newCropFrame = CGRect(
                    x: fromCropFrame.origin.x,
                    y: fromCropFrame.origin.y,
                    width: fromCropFrame.width + translation.x,
                    height: fromCropFrame.height + translation.y
                )
            }
            if newCropFrame.width > fromCropFrame.width {
                newCropFrame.size.width = fromCropFrame.width
            }
            if newCropFrame.height > fromCropFrame.height {
                newCropFrame.size.height = fromCropFrame.height
            }

            self.context = .crop(
                origin: cropOrigin,
                fromCropFrame: fromCropFrame,
                toCropFrame: newCropFrame
            )

            delegate?.changeCropping(fromCropFrame: fromCropFrame, toCropFrame: newCropFrame)
        }
    }

    func end() {
        guard let context else { return }

        switch context {
        case .transform(_, let concatTransform):
            let imgFrame = baseImageFrame
//            let ignoreInvertTransform = CATransform3DConcat(
//                concatTransform,
//                CATransform3DMakeScale(isInvertedHorizontal ? -1 : 1, isInvertedVertical ? -1 : 1, 1)
//            )
            let canvasFrame = transformRect(
                canvasBounds,
                with: CATransform3DInvert(concatTransform),
                coordinate: CGPoint(x: canvasBounds.midX, y: canvasBounds.midY)
            )
            if !imgFrame.contains(canvasFrame) {
                let outMinX = max(imgFrame.minX - canvasFrame.minX, 0)
                let outMinY = max(imgFrame.minY - canvasFrame.minY, 0)
                let outMaxX = max(canvasFrame.maxX - imgFrame.maxX, 0)
                let outMaxY = max(canvasFrame.maxY - imgFrame.maxY, 0)

                let reverseX: CGFloat
                if outMinX > outMaxX {
                    reverseX = -outMinX
                } else {
                    reverseX = outMaxX
                }
                let reverseY: CGFloat
                if outMinY > outMaxY {
                    reverseY = -outMinY
                } else {
                    reverseY = outMaxY
                }

                let reverseTransform = removeTranslation(for: concatTransform)
                let reverseTranslation = transformPoint(
                    CGPoint(x: reverseX, y: reverseY),
                    with: reverseTransform
                )
                let newTransform = CATransform3DConcat(
                    concatTransform,
                    CATransform3DMakeTranslation(reverseTranslation.x, reverseTranslation.y, 0)
                )
                
                transformChanger?.onChange(to: newTransform, immediate: false)
            }

            outBoundsMaskSwitcher?.off()

        case let .crop(origin, fromCropFrame, toCropFrame):
            delegate?.endCropping(
                fromCropFrame: fromCropFrame,
                toLayerFrame: toCropFrame
            )
        }

        self.context = nil
    }
}
