import QuartzCore

extension CAImageCanvasManager: PanGestureMappedCropDelegate {

    func beganCropping() {}

    func changeCropping(fromCropFrame: CGRect, toCropFrame: CGRect) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        needsLayoutCroppingGuide = .crop(toFrame: toCropFrame)
        workspace.setNeedsLayout()
        workspace.layoutIfNeeded()
        CATransaction.commit()
    }

    func endCropping(fromCropFrame: CGRect, toLayerFrame: CGRect) {
        let cropTransition = CATransform3DMakeTranslation(
            fromCropFrame.midX - toLayerFrame.midX,
            fromCropFrame.midY - toLayerFrame.midY,
            0
        )

        // `baseCropFrame` is a normalized frame that fits the image aspect ratio to the crop layer frame.
        let baseCropFrame: CGRect = {
            let imageAspectRatio = CGFloat(image.width) / CGFloat(image.height)
            let cropFrameAspectRatio = toLayerFrame.width / toLayerFrame.height
            let fromFrameAspectRatio = fromCropFrame.width / fromCropFrame.height

            let imageAspectRatioNormalizedFrame: CGRect = {
                if imageAspectRatio > fromFrameAspectRatio {
                    let width = fromCropFrame.height * imageAspectRatio
                    return CGRect(
                        x: fromCropFrame.midX - width / 2,
                        y: fromCropFrame.minY,
                        width: width,
                        height: fromCropFrame.height
                    )
                } else {
                    let height = fromCropFrame.width / imageAspectRatio
                    return CGRect(
                        x: fromCropFrame.minX,
                        y: fromCropFrame.midY - height / 2,
                        width: fromCropFrame.width,
                        height: height
                    )
                }
            }()
            if imageAspectRatio > cropFrameAspectRatio {
                let width = imageAspectRatioNormalizedFrame.height * cropFrameAspectRatio
                return CGRect(
                    x: imageAspectRatioNormalizedFrame.midX - width / 2,
                    y: imageAspectRatioNormalizedFrame.minY,
                    width: width,
                    height: imageAspectRatioNormalizedFrame.height
                )
            } else {
                let height = imageAspectRatioNormalizedFrame.width / cropFrameAspectRatio
                return CGRect(
                    x: imageAspectRatioNormalizedFrame.minX,
                    y: imageAspectRatioNormalizedFrame.midY - height / 2,
                    width: imageAspectRatioNormalizedFrame.width,
                    height: height
                )
            }
        }()
        let scale = baseCropFrame.width / toLayerFrame.width
        let cropScale = CATransform3DMakeScale(scale, scale, 1)
        let cropTransform = CATransform3DConcat(cropTransition, cropScale)

        needsAdjustingTransform = .crop(adjustTransform: { canvasFrame, currentTransform in
            var newTransform = CATransform3DConcat(currentTransform, cropTransform)
            newTransform.m41 *= canvasFrame.width / baseCropFrame.width
            newTransform.m42 *= canvasFrame.height / baseCropFrame.height
            return newTransform
        })
        canvasSize = {
            let toFrameAspectRatio = toLayerFrame.width / toLayerFrame.height
            if image.width > image.height {
                return CGSize(width: CGFloat(image.height) * toFrameAspectRatio, height: CGFloat(image.height))
            } else {
                return CGSize(width: CGFloat(image.width), height: CGFloat(image.width) / toFrameAspectRatio)
            }
        }()

        workspace.setNeedsLayout()
    }
}
