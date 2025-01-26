import QuartzCore

class CATransparentLayer: CADrawOnlyLayer {
    private let step: CGFloat
    private var mutableStepForPointer: CGFloat

    init(step: CGFloat) {
        self.step = step
        self.mutableStepForPointer = step
        super.init()

        needsDisplayOnBoundsChange = true
    }

    override init(layer: Any) {
        if let transparentLayer = layer as? CATransparentLayer {
            self.step = transparentLayer.step
            self.mutableStepForPointer = transparentLayer.mutableStepForPointer
        } else {
            assertionFailure("Only CATransparentLayer can be added.")
            self.step = 10
            self.mutableStepForPointer = 10
        }
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(in ctx: CGContext) {
        guard let pattern = createGridPattern() else { return }

        let colorSpace = CGColorSpace(patternBaseSpace: nil)!
        var alpha: CGFloat = 1.0

        ctx.setFillColorSpace(colorSpace)
        ctx.setFillPattern(pattern, colorComponents: &alpha)
        ctx.fill(bounds)
    }

    func createGridPattern() -> CGPattern? {
        let patternSize = CGSize(width: step * 2, height: step * 2)

        var callbacks = CGPatternCallbacks(
            version: 0,
            drawPattern: { (info, context) in
                guard let step = info?.assumingMemoryBound(to: CGFloat.self).pointee else { return }
                let grayColor = CGColor(gray: 0.925, alpha: 1.0)
                let whiteColor = CGColor(gray: 1.0, alpha: 1.0)
                context.setFillColor(grayColor)
                context.fill(CGRect(x: 0, y: 0, width: step, height: step))
                context.setFillColor(whiteColor)
                context.fill(CGRect(x: 0, y: step, width: step, height: step))
                context.setFillColor(grayColor)
                context.fill(CGRect(x: step, y: step, width: step, height: step))
                context.setFillColor(whiteColor)
                context.fill(CGRect(x: step, y: 0, width: step, height: step))
            },
            releaseInfo: nil
        )

        let stepRawPointer = withUnsafeMutablePointer(to: &mutableStepForPointer) {
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
