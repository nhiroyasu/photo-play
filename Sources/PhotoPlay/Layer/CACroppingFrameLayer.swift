import QuartzCore

class CACroppingFrameLayer: CADrawOnlyLayer {
    private let lineColor: CGColor = Theme.croppingGuideBorder.cgColor
    private let frameOffset: CGFloat

    init(frameOffset: CGFloat) {
        self.frameOffset = frameOffset
        super.init()
        needsDisplayOnBoundsChange = true
        setNeedsDisplay()
    }

    override init(layer: Any) {
        let layer = layer as! CACroppingFrameLayer
        frameOffset = layer.frameOffset
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(in ctx: CGContext) {
        // draw corners
        let cornerSize: CGFloat = 32
        let cornerOffset: CGFloat = frameOffset
        ctx.setFillColor(lineColor)
        ctx.addRect(CGRect(x: 0, y: 0, width: cornerSize, height: cornerOffset))
        ctx.addRect(CGRect(x: 0, y: 0, width: cornerOffset, height: cornerSize))
        ctx.addRect(CGRect(x: bounds.width - cornerSize, y: 0, width: cornerSize, height: cornerOffset))
        ctx.addRect(CGRect(x: bounds.width - cornerOffset, y: 0, width: cornerOffset, height: cornerSize))
        ctx.addRect(CGRect(x: 0, y: bounds.height - cornerOffset, width: cornerSize, height: cornerOffset))
        ctx.addRect(CGRect(x: 0, y: bounds.height - cornerSize, width: cornerOffset, height: cornerSize))
        ctx.addRect(CGRect(x: bounds.width - cornerSize, y: bounds.height - cornerOffset, width: cornerSize, height: cornerOffset))
        ctx.addRect(CGRect(x: bounds.width - cornerOffset, y: bounds.height - cornerSize, width: cornerOffset, height: cornerSize))
        ctx.fillPath()
    }
}
