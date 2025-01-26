import QuartzCore

class CAPaintableLayer: CAEditableShapeLayer {
    init(
        frame: CGRect,
        displayName: String
    ) {
        super.init(isSelectable: false, isTransformable: false)

        self.frame = frame
        self.contentsScale = DEVICE_SCREEN_SCALE
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
