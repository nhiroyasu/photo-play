import QuartzCore
import Combine

class CASelectionFrameLayer: CADrawOnlyLayer {
    typealias TargetLayer = CALayer

    let targetLayer: TargetLayer

    private let BORDER_WIDTH: CGFloat = 1.0
    private let BORDER_COLOR: CGColor = Theme.selectionBorder.cgColor

    private var cancellable: [AnyCancellable] = []

    private var drawingFrame: CGRect = .zero

    init(
        targetLayer: TargetLayer,
        frame: CGRect,
        contentsScale: CGFloat
    ) {
        self.targetLayer = targetLayer
        super.init()

        self.frame = frame
        self.contentsScale = contentsScale
//        targetLayer.publisher(for: \.position, options: [.new])
//            .sink { [weak self] _ in
//                self?.redraw()
//            }
//            .store(in: &cancellable)
//        redraw(frameInWorkspace: targetLayer.frame)
    }

    override init(layer: Any) {
        let selectionFrameLayer = layer as! CASelectionFrameLayer
        self.targetLayer = selectionFrameLayer.targetLayer
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func redraw(frameInWorkspace: CGRect) {
        drawingFrame = frameInWorkspace
        setNeedsDisplay()
        displayIfNeeded()
    }

    override func draw(in ctx: CGContext) {
        ctx.setStrokeColor(BORDER_COLOR)
        ctx.setLineWidth(BORDER_WIDTH)
        ctx.setLineDash(phase: 0, lengths: [4, 4])
        ctx.addPath(drawingFrame.path())
        ctx.drawPath(using: .stroke)
    }
}
