import QuartzCore

class CAOutBoundsMaskLayer: CALayer {
    var canvasFrame: CGRect = .zero {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(in ctx: CGContext) {
        let outBoundsColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0.2)
        let inBoundsColor = CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 1.0)

        ctx.setFillColor(outBoundsColor)
        ctx.fill(bounds)

        ctx.setFillColor(inBoundsColor)
        ctx.fill(canvasFrame)
    }
}
