import QuartzCore

class CADrawOnlyLayer: CALayer {
    override public func render(in ctx: CGContext) {
        // Do nothing
    }
}

class CAExportOnlyLayer: CALayer {
    override public func draw(in ctx: CGContext) {
        // Do nothing
    }
}
