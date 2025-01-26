import QuartzCore

class CACanvasLayer: CAEditableContainerLayer {
    typealias Layer = any CALayer & EditableLayer

    init(backgroundColor: CGColor) {
        super.init()

        self.backgroundColor = backgroundColor
        self.masksToBounds = true
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
