import CoreImage
import CoreGraphics

func drawImage(
    cgContext: CGContext,
    ciContext: CIContext,
    in frame: CGRect,
    layerFrame: CGRect,
    image: CIImage,
    imageWidth: Int,
    imageHeight: Int
) {
    cgContext.translateBy(x: 0, y: layerFrame.height)
    cgContext.scaleBy(x: 1.0, y: -1.0)
    ciContext.draw(
        image,
        in: frame,
        from: .init(
            x: 0,
            y: 0,
            width: imageWidth,
            height: imageHeight
        )
    )
}

func drawSelectionFrame(
    in ctx: CGContext,
    drawingSize: CGSize,
    borderColor: CGColor,
    borderWidth: CGFloat,
    lineDashLength: CGFloat
) {
    ctx.setStrokeColor(borderColor)
    ctx.setLineWidth(borderWidth)
    ctx.setLineDash(phase: 0, lengths: [lineDashLength, lineDashLength])
    ctx.addPath(drawingSize.path())
    ctx.strokePath()
}
