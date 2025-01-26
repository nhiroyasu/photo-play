import QuartzCore

class CAEraserMaskLayer: CALayer {
    private let mutablePath = CGMutablePath()
    private let smoothingWindowSize = 5

    private var rawPoints: [CGPoint] = []
    private var smoothedPoints: [CGPoint] = []

    init(frame: CGRect) {
        super.init()

        self.frame = frame
        self.contentsScale = DEVICE_SCREEN_SCALE
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func beginPainting(at point: CGPoint) {
        mutablePath.move(to: point)
        rawPoints = [point]
        smoothedPoints = [point]
    }

    func paint(to point: CGPoint) {
        rawPoints.append(point)

        let smoothPoint = smoothPoint(points: rawPoints, windowSize: smoothingWindowSize)
        smoothedPoints.append(smoothPoint)

        let previousPoint = smoothedPoints[smoothedPoints.count - 2]
        let midPoint = midpoint(previousPoint, smoothPoint)
        mutablePath.addQuadCurve(to: midPoint, control: previousPoint)

        setNeedsDisplay()
        displayIfNeeded()
    }

    func endPainting() {
        rawPoints = []
        smoothedPoints = []
    }

    override func draw(in ctx: CGContext) {
        ctx.setBlendMode(.normal)
        ctx.setFillColor(CGColor(gray: 0, alpha: 1))
        ctx.fill(bounds)

        ctx.setBlendMode(.clear)
        ctx.setLineWidth(20.0)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        ctx.addPath(mutablePath)
        ctx.strokePath()
    }

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
}

var maskBaseCGLayer: CGLayer?
