import QuartzCore

class RawTouchMappedEraser: CanvasRawTouchMappable {
    private let paintLayer: CAPaintLayer
    weak var coordinateDelegate: (any CanvasCoordinateConvertable)!

    init(
        paintLayer: CAPaintLayer,
        coordinateDelegate: any CanvasCoordinateConvertable
    ) {
        self.paintLayer = paintLayer
        self.coordinateDelegate = coordinateDelegate
    }

    func began(_ position: CGPoint) {
        paintLayer.beginErasing(
            at: coordinateDelegate.convert(workspacePoint: position, to: paintLayer)
        )
    }

    func move(_ position: CGPoint) {
        paintLayer.erase(
            to: coordinateDelegate.convert(workspacePoint: position, to: paintLayer)
        )
    }

    func end() {
        paintLayer.endErasing()
    }

    func cancel() {
        paintLayer.endErasing()
    }
}
