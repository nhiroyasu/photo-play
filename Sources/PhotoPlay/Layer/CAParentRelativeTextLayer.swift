import QuartzCore
import CoreText

class CAParentRelativeTextLayer: CAParentRelativeLayer {
    let drawingLayer: CGLayer!

    init(
        text: String,
        fontName: String,
        fontSize: CGFloat,
        foregroundColor: CGColor,
        contentsScale: CGFloat,
        parentBounds: CGRect,
        relativePoint: CGPoint = CGPoint(x: 0.5, y: 0.5),
        relativeRotation: CGFloat = 0
    ) {
        let font = CTFontCreateWithName(fontName as CFString, fontSize * contentsScale, nil)
        let line = CTLineCreateWithAttributedString(
            NSAttributedString(string: text, attributes: [
                .font: font,
                .foregroundColor: foregroundColor
            ])
        )
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        var leading: CGFloat = 0
        let width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
        let height = ascent + descent
        let textSize = CGSize(width: CGFloat(width), height: height)

        self.drawingLayer = CGLayer(
            CGContext(
                data: nil,
                width: Int(textSize.width),
                height: Int(textSize.height),
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )!,
            size: textSize,
            auxiliaryInfo: nil
        )!
        if let ctx = drawingLayer.context {
            ctx.translateBy(x: 0, y: textSize.height)
            ctx.scaleBy(x: 1, y: -1)
            ctx.textPosition = .init(x: 0, y: descent)
            CTLineDraw(line, ctx)
        }

        super.init(
            relativePoint: relativePoint,
            relativeScale: .init(
                width: textSize.width / contentsScale / parentBounds.width,
                height: textSize.height / contentsScale / parentBounds.height
            ),
            relativeRotation: relativeRotation
        )

        self.contentsScale = contentsScale
        self.needsDisplayOnBoundsChange = true
    }

    override init(layer: Any) {
        if let canvasRelativeLayer = layer as? CAParentRelativeTextLayer {
            self.drawingLayer = canvasRelativeLayer.drawingLayer
        } else {
            fatalError("Only CAParentRelativeTextLayer can be added.")
        }
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        ctx.draw(drawingLayer, in: bounds)
    }
}
