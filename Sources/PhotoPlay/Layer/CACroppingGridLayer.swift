import QuartzCore

class CACroppingGridLayer: CADrawOnlyLayer {
    private let gridStep: CGFloat = 3
    private let lineColor: CGColor = Theme.croppingGuideBorder.cgColor

    private var mutablePatternInfo: CGPatternInfo = .init(stepSize: .zero, contentsScale: 1.0, lineColor: .init(gray: 0.12, alpha: 1.0))
    struct CGPatternInfo {
        let stepSize: CGSize
        let contentsScale: CGFloat
        let lineColor: CGColor
    }

    override init() {
        super.init()
        needsDisplayOnBoundsChange = true
        setNeedsDisplay()
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(in ctx: CGContext) {
        guard let pattern = createGridPattern(
            widthStep: ceil(bounds.width / gridStep),
            heightStep: ceil(bounds.height / gridStep)
        ) else { return }

        let colorSpace = CGColorSpace(patternBaseSpace: nil)!
        var alpha: CGFloat = 1.0

        // fill grid
        ctx.setFillColorSpace(colorSpace)
        ctx.setFillPattern(pattern, colorComponents: &alpha)
        ctx.fill(bounds)

        // draw border
        let lineWidth = 1.0 / contentsScale
        ctx.setStrokeColor(lineColor)
        ctx.setLineWidth(lineWidth)
        ctx.addRect(bounds.insetBy(dx: lineWidth, dy: lineWidth))
        ctx.strokePath()
    }

    func createGridPattern(widthStep: CGFloat, heightStep: CGFloat) -> CGPattern? {
        let patternSize = CGSize(width: widthStep, height: heightStep)

        var callbacks = CGPatternCallbacks(
            version: 0,
            drawPattern: { (info, context) in
                guard let info = info?.assumingMemoryBound(to: CGPatternInfo.self).pointee else { return }
                context.setStrokeColor(info.lineColor)
                context.setLineWidth(1.0 / info.contentsScale)
                context.addRect(CGRect(x: 0, y: 0, width: info.stepSize.width, height: info.stepSize.height))
                context.strokePath()
            },
            releaseInfo: nil
        )

        mutablePatternInfo = .init(
            stepSize: patternSize,
            contentsScale: contentsScale,
            lineColor: lineColor
        )
        let stepRawPointer = withUnsafeMutablePointer(to: &mutablePatternInfo) {
            UnsafeMutableRawPointer($0)
        }

        return CGPattern(
            info: stepRawPointer,
            bounds: CGRect(origin: .zero, size: patternSize),
            matrix: .identity,
            xStep: patternSize.width,
            yStep: patternSize.height,
            tiling: .constantSpacing,
            isColored: true,
            callbacks: &callbacks
        )
    }
}
