import QuartzCore

class CAParentRelativeLayer: CAEditableLayer, ParentRelativeLayer {
    var relativePoint: CGPoint
    var relativeScale: CGSize
    var relativeRotation: CGFloat

    init(
        relativePoint: CGPoint,
        relativeScale: CGSize,
        relativeRotation: CGFloat
    ) {
        self.relativePoint = relativePoint
        self.relativeScale = relativeScale
        self.relativeRotation = relativeRotation
        super.init()
    }

    override init(layer: Any) {
        if let canvasRelativeLayer = layer as? CAParentRelativeLayer {
            self.relativePoint = canvasRelativeLayer.relativePoint
            self.relativeScale = canvasRelativeLayer.relativeScale
            self.relativeRotation = canvasRelativeLayer.relativeRotation
        } else {
            fatalError("Only CACanvasRelativeLayer can be added.")
        }
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func relativeLayout(parentBounds: CGRect) {
        self.transform = CATransform3DIdentity
        let width = parentBounds.width * relativeScale.width
        let height = parentBounds.height * relativeScale.height
        self.frame = CGRect(
            x: parentBounds.width * relativePoint.x - width / 2,
            y: parentBounds.height * relativePoint.y - height / 2,
            width: width,
            height: height
        )
        self.transform = CATransform3DMakeRotation(relativeRotation, 0, 0, 1)
    }
}
