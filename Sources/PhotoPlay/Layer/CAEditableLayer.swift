import QuartzCore

class CAEditableLayer: CALayer, EditableLayer {
    public let id: UUID
    public let isSelectable: Bool
    public let isTransformable: Bool

    private var selectionFrameDrawingLayer: CGLayer?

    init(
        isSelectable: Bool = true,
        isTransformable: Bool = true
    ) {
        self.id = UUID()
        self.isSelectable = isSelectable
        self.isTransformable = isTransformable
        super.init()
    }

    public override init(layer: Any) {
        if let editableLayer = layer as? CAEditableLayer {
            self.id = editableLayer.id
            self.isSelectable = editableLayer.isSelectable
            self.isTransformable = editableLayer.isTransformable
        } else {
            assertionFailure("Only EditableLayer can be added.")
            self.id = UUID()
            self.isSelectable = true
            self.isTransformable = true
        }
        super.init(layer: layer)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)

        if let selectionFrameDrawingLayer = self.selectionFrameDrawingLayer {
            ctx.draw(selectionFrameDrawingLayer, in: bounds)
        }
    }

    func drawSelectionFrame(in frame: CGRect) {
        let borderColor = Theme.selectionBorder.cgColor
        let borderWidth = 3.0 * contentsScale
        let lineDashLength: CGFloat = 4.0 * contentsScale
        let drawingSize = frame.size.scale(by: contentsScale)

        let baseCGContext = CGContextBuilder(
            width: drawingSize.width,
            height: drawingSize.height
        )

        if let baseCGContext,
           let cgLayer = CGLayer(baseCGContext, size: drawingSize, auxiliaryInfo: nil),
           let cgLayerContext = cgLayer.context {

            PhotoPlay.drawSelectionFrame(
                in: cgLayerContext,
                drawingSize: drawingSize,
                borderColor: borderColor,
                borderWidth: borderWidth,
                lineDashLength: lineDashLength
            )
            self.selectionFrameDrawingLayer = cgLayer

            self.setNeedsDisplay()
        }
    }

    func deleteSelectionFrame() {
        self.selectionFrameDrawingLayer = nil
        self.setNeedsDisplay()
    }
}
