import QuartzCore

class CACroppingGuideLayer: CADrawOnlyLayer {
    let frameOffset: CGFloat
    let croppingFrameLayer: CACroppingFrameLayer
    let croppingGridLayer: CACroppingGridLayer

    override var contentsScale: CGFloat {
        didSet {
            croppingFrameLayer.contentsScale = contentsScale
            croppingGridLayer.contentsScale = contentsScale
        }
    }

    init(frameOffset: CGFloat) {
        self.frameOffset = frameOffset
        croppingFrameLayer = .init(frameOffset: frameOffset)
        croppingGridLayer = .init()
        super.init()

        sublayers = [croppingGridLayer, croppingFrameLayer]
        needsDisplayOnBoundsChange = true
        setNeedsDisplay()
    }

    override init(layer: Any) {
        let layer = layer as! CACroppingGuideLayer
        frameOffset = layer.frameOffset
        croppingFrameLayer = .init(layer: layer.croppingFrameLayer)
        croppingGridLayer = .init(layer: layer.croppingGridLayer)
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers() {
        croppingFrameLayer.frame = bounds
        croppingGridLayer.frame = bounds.insetBy(dx: frameOffset, dy: frameOffset)
    }
}
