import QuartzCore

class RawTouchMappedPaintingLine: CanvasRawTouchMappable {
    private unowned let paintLayer: CAPaintLayer
    private unowned let coordinateDelegate: any CanvasCoordinateConvertable

    init(
        paintLayer: CAPaintLayer,
        coordinateDelegate: any CanvasCoordinateConvertable
    ) {
        self.paintLayer = paintLayer
        self.coordinateDelegate = coordinateDelegate
    }

    func began(_ point: CGPoint) {
        paintLayer.beginPainting(
            at: coordinateDelegate.convert(workspacePoint: point, to: paintLayer)
        )
    }

    func move(_ point: CGPoint) {
        paintLayer.paint(
            to: coordinateDelegate.convert(workspacePoint: point, to: paintLayer)
        )
    }

    func end() {
        paintLayer.endPainting()
    }

    func cancel() {
        paintLayer.endPainting()
    }
}
