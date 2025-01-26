import QuartzCore

class CASelectionOwnerLayer: CADrawOnlyLayer {
    enum SelectOption {
        case single
        case multiple
    }

    typealias Layer = CASelectionFrameLayer

    private var selectionFrameLayers: [Layer] {
        sublayers?.compactMap { $0 as? Layer } ?? []
    }

    public override func addSublayer(_ layer: CALayer) {
        if let layer = layer as? Layer {
            super.addSublayer(layer)
        } else {
            assertionFailure("Only CASelectionFrameLayer can be added.")
        }
    }

    public override var sublayers: [CALayer]? {
        set {
            if newValue?.allSatisfy({ $0 is Layer }) == true {
                self.sublayers = newValue
            } else {
                assertionFailure("Only CASelectionFrameLayer can be added.")
            }
        }
        get {
            super.sublayers
        }
    }

    func isSelecting(for layer: Layer.TargetLayer) -> Bool {
        selectionFrameLayers.contains { $0.targetLayer == layer }
    }

    func selectingLayers() -> [Layer.TargetLayer] {
        selectionFrameLayers.map { $0.targetLayer }
    }

    func select(for layer: some Layer.TargetLayer, option: SelectOption = .single) {
        guard selectionFrameLayers.allSatisfy({ $0.targetLayer != layer }) else { return }
        switch option {
        case .single:
            selectionFrameLayers.forEach { $0.removeFromSuperlayer() }
            addSublayer(CASelectionFrameLayer(targetLayer: layer, frame: bounds, contentsScale: contentsScale))
        case .multiple:
            addSublayer(CASelectionFrameLayer(targetLayer: layer, frame: bounds, contentsScale: contentsScale))
        }
    }

    func drawIfNeeded(for layer: some Layer.TargetLayer, frameInWorkspace: CGRect) {
        guard let layer = selectionFrameLayers.first(where: { $0.targetLayer == layer }) else { return }
        layer.redraw(frameInWorkspace: frameInWorkspace)
    }

    func deselect(for layer: Layer.TargetLayer) {
        guard let layer = selectionFrameLayers.first(where: { $0.targetLayer == layer }) else { return }
        layer.removeFromSuperlayer()
    }

    func deselectAll() {
        selectionFrameLayers.forEach { $0.removeFromSuperlayer() }
    }

    override func layoutSublayers() {
        selectionFrameLayers.forEach { $0.frame = bounds }
    }
}


class CADrawingSelectionFrameLayer: CADrawOnlyLayer {
    private var selectionFramePaths: [CGPath] = []

    func drawSelectionFrame(_ paths: [CGPath]) {
        selectionFramePaths = paths
        setNeedsDisplay()
    }

    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)

        let borderColor = Theme.selectionBorder.cgColor
        let borderWidth: CGFloat = 2.0
        let lineDashLength: CGFloat = 4.0

        for path in selectionFramePaths {
            ctx.setStrokeColor(borderColor)
            ctx.setLineWidth(borderWidth)
            ctx.setLineDash(phase: 0, lengths: [lineDashLength, lineDashLength])
            ctx.addPath(path)
            ctx.strokePath()
        }
    }
}
