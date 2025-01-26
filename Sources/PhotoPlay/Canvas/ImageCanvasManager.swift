import QuartzCore
import Combine
import CoreImage

public protocol ImageCanvasManager: CanvasManager, GestureMappableCanvasManager, RawTouchMappableCanvasManager {
    // State Management
    var operation: ImageCanvasOperation { get }
    func setOperation(_ operation: ImageCanvasOperation)
    func operationPublisher() -> AnyPublisher<ImageCanvasOperation, Never>
    var pen: Pen { get }
    func setPen(_ pen: Pen)
    func penPublisher() -> AnyPublisher<Pen, Never>

    // Canvas
    func resizeCanvas(size: ImageSize)

    // Image Filter
    func applyImageFilter(_ imageFilters: [ImageFilter], asyncRendering: Bool)

    // Eraser
    func setEraserSize(_ size: CGFloat)

    // Overlay
    func addText(
        text: String,
        fontName: String,
        fontSize: CGFloat,
        color: CGColor
    )
    func addImage(
        image: CGImage
    )

    // Transform
    func resetCrop()
    func rotateCanvasRightAngle90()
    func invertVertical()
    func invertHorizontal()
}
