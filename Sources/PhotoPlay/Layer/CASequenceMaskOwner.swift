import QuartzCore

class CASequenceMaskOwner {
    let rootLayer: CALayer
    private var currentLayer: CALayer

    init(frame: CGRect) {
        rootLayer = CALayer()
        rootLayer.frame = frame
        currentLayer = CALayer()
        currentLayer.frame = frame
        rootLayer.addSublayer(currentLayer)
    }

    func apply(mask: CALayer) {
        let maskedLayer = currentLayer
        maskedLayer.mask = mask
        maskedLayer.removeFromSuperlayer()

        currentLayer = CALayer()
        currentLayer.frame = maskedLayer.frame
        currentLayer.addSublayer(maskedLayer)

        rootLayer.addSublayer(currentLayer)
    }

    func add(layer: CALayer) {
        currentLayer.addSublayer(layer)
    }

    func undo() {
        if let lastLayer = currentLayer.sublayers?.last {
            if lastLayer.mask != nil {
                lastLayer.mask = nil
                currentLayer.removeFromSuperlayer()
                rootLayer.addSublayer(currentLayer)

                currentLayer = lastLayer
            } else {
                lastLayer.removeFromSuperlayer()
            }
        }
    }

    func attach(to layer: CALayer) {
        layer.addSublayer(rootLayer)
    }
}
