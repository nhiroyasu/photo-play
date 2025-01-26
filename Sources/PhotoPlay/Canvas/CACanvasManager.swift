import QuartzCore
import Combine
import CoreText

open class CACanvasManager: NSObject, CanvasManager, CanvasCoordinateConvertable, CALayerDelegate {
    let workspace: CAWorkspaceLayer
    let canvas: CACanvasLayer
    weak var rootLayer: CALayer?

    let renderer = Renderer()

    var canvasSize: CGSize

    init(canvasSize: CGSize) {
        self.canvas = CACanvasLayer(backgroundColor: CGColor(gray: 1.0, alpha: 1.0))
        self.canvas.name = PHOTO_PLAY_CANVAS_LAYER

        self.workspace = CAWorkspaceLayer()
        self.workspace.sublayers = [
            canvas
        ]
        self.workspace.name = PHOTO_PLAY_WORKSPACE_LAYER

        self.canvasSize = canvasSize
    }

    // MARK: - Set up

    public func display(in layer: CALayer) {
        self.rootLayer = layer
        layer.name = PHOTO_PLAY_ROOT_LAYER
        layer.sublayers = [workspace]
        layer.delegate = self
        layer.setNeedsDisplay()
    }

    // MARK: - Layers

    public func resizeCanvas(size: CGSize) {
        self.canvasSize = size
        workspace.setNeedsLayout()
    }


    // MARK: - Rendering

    public func render() -> RenderingContext? {
        let renderingContext = renderer.render(
            for: canvas,
            width: Int(canvasSize.width),
            height: Int(canvasSize.height),
            quality: .high
        )
        return renderingContext
    }

    // MARK: - Coordinate

    func convert(workspacePoint: CGPoint, to layer: CALayer) -> CGPoint {
        workspace.convert(workspacePoint, to: layer)
    }

    // MARK: - Layer Delegate

    public func layoutSublayers(of layer: CALayer) {
        switch layer.name {
        case PHOTO_PLAY_ROOT_LAYER:
            workspace.frame = layer.bounds
        default:
            break
        }
    }
}
