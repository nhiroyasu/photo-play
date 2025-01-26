import QuartzCore

class CAEditableContainerLayer: CAEditableLayer, EditableContainerLayer {
    init() {
        super.init(isSelectable: false, isTransformable: false)
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var editableLayers: [Layer] {
        sublayers?.compactMap { $0 as? Layer } ?? []
    }

    override func addSublayer(_ layer: CALayer) {
        if let layer = layer as? Layer {
            super.addSublayer(layer)
        } else {
            assertionFailure("Only EditableLayer can be added.")
        }
    }

    override var sublayers: [CALayer]? {
        set {
            if newValue?.allSatisfy({ $0 is Layer }) == true {
                super.sublayers = newValue
            } else {
                assertionFailure("Only EditableLayer can be added.")
            }
        }
        get {
            super.sublayers
        }
    }

    func hitSelectable(at position: CGPoint) -> Layer? {
        let hitLayers = editableLayers
            .filter { $0.isSelectable }
            .filter { $0.containsConsideringTransform(position) }
        let hitLayerMostFront = hitLayers.reversed().max { $0.zPosition < $1.zPosition }
        return hitLayerMostFront
    }

    func hitTransformable(at position: CGPoint) -> Layer? {
        let hitLayers = editableLayers
            .filter { $0.isTransformable }
            .filter { $0.containsConsideringTransform(position) }
        let hitLayerMostFront = hitLayers.reversed().max { $0.zPosition < $1.zPosition }
        return hitLayerMostFront
    }
}
