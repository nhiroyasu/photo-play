import QuartzCore
import CoreText
import Combine

class CAPaintLayer: CAEditableLayer {
    let drawingSize: CGSize
    var drawingLayer: CGLayer
    var pen: Pen
    private var penSize: CGFloat {
        switch pen {
        case let .gPen(_, size):
            return size
        }
    }
    var eraserSize: CGFloat

    public init(
        size drawingSize: CGSize,
        pen: Pen = .gPen(color: .init(gray: 0, alpha: 1.0), size: 0.0),
        eraseSize: CGFloat = 10.0
    ) {
        self.pen = pen
        self.eraserSize = eraseSize
        self.drawingSize = drawingSize

        let ctx = CGContext(
            data: nil,
            width: Int(drawingSize.width),
            height: Int(drawingSize.height),
            bitsPerComponent: 8,
            bytesPerRow: 4 * Int(drawingSize.width),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        self.drawingLayer = CGLayer(ctx, size: drawingSize, auxiliaryInfo: nil)!

        super.init(
            isSelectable: false,
            isTransformable: false
        )

        self.masksToBounds = false
    }

    override init(layer: Any) {
        if let layer = layer as? CAPaintLayer {
            self.pen = layer.pen
            self.eraserSize = layer.eraserSize
            self.drawingSize = layer.drawingSize
            self.drawingLayer = layer.drawingLayer
        } else {
            fatalError("Only CAPaintLayer can be added.")
        }
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    override func draw(in ctx: CGContext) {
        ctx.draw(drawingLayer, in: bounds)
        ctx.translateBy(x: 0, y: bounds.height)
        ctx.scaleBy(x: 1, y: -1)
    }

    // MARK: - Paint

    private let smoothingWindowSize = 5
    private var rawPoints: [CGPoint] = []
    private var smoothedPoints: [CGPoint] = []
    private var previousPoint: CGPoint = .zero

    private var oneStrokePath: CGMutablePath = .init()

    func beginPainting(at point: CGPoint) {
        guard let ctx = drawingLayer.context else { return }
        let drawingPoint = convertDrawCoordinate(at: point)

        ctx.saveGState()
        ctx.setBlendMode(.normal)
        switch pen {
        case let .gPen(color, size):
            ctx.setLineWidth(size)
            ctx.setStrokeColor(color)
            ctx.setLineCap(.round) // NOTE: If changed, change the corresponding value in operationStack
            ctx.setLineJoin(.round) // NOTE: If changed, change the corresponding value in operationStack
        }

        previousPoint = drawingPoint
        rawPoints = [drawingPoint]
        smoothedPoints = [drawingPoint]

        oneStrokePath = .init()
        oneStrokePath.move(to: drawingPoint)
        undoStack = []
    }

    func paint(to point: CGPoint) {
        guard let ctx = drawingLayer.context else { return }
        let drawingPoint = convertDrawCoordinate(at: point)

        rawPoints.append(drawingPoint)
        let smoothPoint = smoothPoint(points: rawPoints, windowSize: smoothingWindowSize)
        smoothedPoints.append(smoothPoint)

        let previousSmoothedPoint = smoothedPoints[smoothedPoints.count - 2]
        let currentPoint = midpoint(previousSmoothedPoint, smoothPoint)

        let path = CGMutablePath()
        path.move(to: previousPoint)
        path.addQuadCurve(to: currentPoint, control: previousSmoothedPoint)
        ctx.addPath(path)
        ctx.strokePath()

        let penBounds = path.boundingBoxOfPath.insetBy(dx: -penSize, dy: -penSize)
        setNeedsDisplay(convertLayerCoordinate(rect: penBounds))

        previousPoint = currentPoint

        oneStrokePath.addPath(path)
    }

    func endPainting() {
        switch pen {
        case let .gPen(color, size):
            operationStack.append(.paint(
                path: oneStrokePath,
                color: color,
                size: size,
                blendMode: .normal,
                lineCap: .round,
                lineJoin: .round
            ))
        }

        if let ctx = drawingLayer.context {
            ctx.restoreGState()
        }
    }

    func beginErasing(at point: CGPoint) {
        guard let ctx = drawingLayer.context else { return }
        let drawingPoint = convertDrawCoordinate(at: point)

        ctx.saveGState()
        ctx.setLineWidth(eraserSize)
        ctx.setBlendMode(.clear)
        ctx.setLineCap(.round) // NOTE: If changed, change the corresponding value in operationStack
        ctx.setLineJoin(.round) // NOTE: If changed, change the corresponding value in operationStack

        previousPoint = drawingPoint
        rawPoints = [drawingPoint]
        smoothedPoints = [drawingPoint]

        oneStrokePath = .init()
        oneStrokePath.move(to: drawingPoint)
        undoStack = []
    }

    func erase(to point: CGPoint) {
        guard let ctx = drawingLayer.context else { return }
        let drawingPoint = convertDrawCoordinate(at: point)

        rawPoints.append(drawingPoint)
        let smoothPoint = smoothPoint(points: rawPoints, windowSize: smoothingWindowSize)
        smoothedPoints.append(smoothPoint)

        let previousSmoothedPoint = smoothedPoints[smoothedPoints.count - 2]
        let currentPoint = midpoint(previousSmoothedPoint, smoothPoint)

        let path = CGMutablePath()
        path.move(to: previousPoint)
        path.addQuadCurve(to: currentPoint, control: previousSmoothedPoint)
        ctx.addPath(path)
        ctx.strokePath()

        let eraseBounds = path.boundingBoxOfPath.insetBy(dx: -eraserSize, dy: -eraserSize)
        setNeedsDisplay(convertLayerCoordinate(rect: eraseBounds))

        previousPoint = currentPoint

        oneStrokePath.addPath(path)
    }

    func endErasing() {
        operationStack.append(.erase(
            path: oneStrokePath,
            size: eraserSize,
            lineCap: .round,
            lineJoin: .round
        ))

        if let ctx = drawingLayer.context {
            ctx.restoreGState()
        }
    }

    func drawText(_ attributeString: NSAttributedString, at position: CGPoint) {
        guard let ctx = drawingLayer.context else { return }

        let line = CTLineCreateWithAttributedString(attributeString)
        let size = computeFontSize(line: line)

        ctx.saveGState()

        ctx.translateBy(x: 0, y: CGFloat(size.height))
        ctx.scaleBy(x: 1.0, y: -1.0)

        let drawingPoint = convertDrawCoordinate(at: position)
        ctx.textPosition = drawingPoint
        CTLineDraw(line, ctx)

        ctx.restoreGState()

        setNeedsDisplay(convertLayerCoordinate(rect: CGRect(origin: position, size: size)))
    }

    // MARK: - History Operation

    private var operationStack: [PaintOperation] = [] {
        didSet {
            operationStackSubject.send(operationStack)
        }
    }
    private var undoStack: [PaintOperation] = [] {
        didSet {
            undoStackSubject.send(undoStack)
        }
    }
    private let operationStackSubject: PassthroughSubject<[PaintOperation], Never> = .init()
    private let undoStackSubject: PassthroughSubject<[PaintOperation], Never> = .init()

    enum PaintOperation {
        case paint(path: CGPath, color: CGColor, size: CGFloat, blendMode: CGBlendMode, lineCap: CGLineCap, lineJoin: CGLineJoin)
        case erase(path: CGPath, size: CGFloat, lineCap: CGLineCap, lineJoin: CGLineJoin)
    }

    func undo() {
        guard let lastOperation = operationStack.popLast() else { return }
        undoStack.append(lastOperation)

        let ctx = CGContext(
            data: nil,
            width: Int(drawingSize.width),
            height: Int(drawingSize.height),
            bitsPerComponent: 8,
            bytesPerRow: 4 * Int(drawingSize.width),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        drawingLayer = CGLayer(ctx, size: drawingSize, auxiliaryInfo: nil)!
        guard let ctx = drawingLayer.context else { return }

        ctx.saveGState()
        for operation in operationStack {
            switch operation {
            case let .paint(path, color, size, blendMode, lineCap, lineJoin):
                ctx.setBlendMode(blendMode)
                ctx.setLineWidth(size)
                ctx.setStrokeColor(color)
                ctx.setLineCap(lineCap)
                ctx.setLineJoin(lineJoin)
                ctx.addPath(path)
                ctx.strokePath()
            case let .erase(path, size, lineCap, lineJoin):
                ctx.setLineWidth(size)
                ctx.setBlendMode(.clear)
                ctx.setLineCap(lineCap)
                ctx.setLineJoin(lineJoin)
                ctx.addPath(path)
                ctx.strokePath()
            }
        }
        ctx.restoreGState()

        setNeedsDisplay()
    }

    func redo() {
        guard let ctx = drawingLayer.context else { return }
        guard let lastUndoOperation = undoStack.popLast() else { return }
        operationStack.append(lastUndoOperation)

        ctx.saveGState()
        switch lastUndoOperation {
        case let .paint(path, color, size, blendMode, lineCap, lineJoin):
            ctx.setBlendMode(blendMode)
            ctx.setLineWidth(size)
            ctx.setStrokeColor(color)
            ctx.setLineCap(lineCap)
            ctx.setLineJoin(lineJoin)
            ctx.addPath(path)
            ctx.strokePath()
        case let .erase(path, size, lineCap, lineJoin):
            ctx.setLineWidth(size)
            ctx.setBlendMode(.clear)
            ctx.setLineCap(lineCap)
            ctx.setLineJoin(lineJoin)
            ctx.addPath(path)
            ctx.strokePath()
        }
        ctx.restoreGState()

        setNeedsDisplay()
    }

    func canUndo() -> Bool {
        return !operationStack.isEmpty
    }

    func canRedo() -> Bool {
        return !undoStack.isEmpty
    }

    func canUndoPublisher() -> AnyPublisher<Bool, Never> {
        operationStackSubject
            .map { !$0.isEmpty }
            .eraseToAnyPublisher()
    }

    func canRedoPublisher() -> AnyPublisher<Bool, Never> {
        undoStackSubject
            .map { !$0.isEmpty }
            .eraseToAnyPublisher()
    }

    // MARK: - Helpers

    private func smoothPoint(points: [CGPoint], windowSize: Int) -> CGPoint {
        let count = points.count
        guard count > 0 else { return .zero }

        let windowPoints = points.suffix(windowSize)

        let sum = windowPoints.reduce(CGPoint.zero) { result, point in
            CGPoint(x: result.x + point.x, y: result.y + point.y)
        }

        return CGPoint(x: sum.x / CGFloat(windowPoints.count), y: sum.y / CGFloat(windowPoints.count))
    }

    private func midpoint(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }

    private func convertDrawCoordinate(at layerPoint: CGPoint) -> CGPoint {
        let ratio = drawingSize.width / bounds.width
        return CGPoint(
            x: layerPoint.x * ratio,
            y: layerPoint.y * ratio
        )
    }

    private func convertLayerCoordinate(rect: CGRect) -> CGRect {
        let ratio = bounds.width / drawingSize.width
        return CGRect(
            x: rect.origin.x * ratio,
            y: rect.origin.y * ratio,
            width: rect.width * ratio,
            height: rect.height * ratio
        )
    }

    private func computeFontSize(line: CTLine) -> CGSize {
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        var leading: CGFloat = 0
        let width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
        let height = ascent + descent
        return CGSize(width: CGFloat(width), height: height)
    }
}
