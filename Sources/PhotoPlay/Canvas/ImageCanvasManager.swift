import QuartzCore
import Combine
import CoreImage

public protocol ImageCanvasManager: CanvasManager, GestureMappableCanvasManager, RawTouchMappableCanvasManager {
    // State Management
    var operation: ImageCanvasOperation { get }
    var pen: Pen { get }
    var eraserSize: CGFloat { get }

    func setOperation(_ operation: ImageCanvasOperation)
    func setPen(_ pen: Pen)
    func setEraserSize(_ size: CGFloat)

    func operationPublisher() -> AnyPublisher<ImageCanvasOperation, Never>
    func penPublisher() -> AnyPublisher<Pen, Never>
    func eraserSizePublisher() -> AnyPublisher<CGFloat, Never>
    
    func selectionStatePublisher() -> AnyPublisher<Bool, Never>

    // Canvas
    func resizeCanvas(size: ImageSize)

    // Image Filter
    func applyImageFilter(_ imageFilters: [ImageFilter], asyncRendering: Bool)

    // Paint
    func undoPaint()
    func redoPaint()
    func canUndoPaint() -> Bool
    func canRedoPaint() -> Bool
    func canUndoPaintPublisher() -> AnyPublisher<Bool, Never>
    func canRedoPaintPublisher() -> AnyPublisher<Bool, Never>

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
    func removeSelectingLayer()

    // Transform
    func resetCrop()
    func rotateCanvasRightAngle90()
    func invertVertical()
    func invertHorizontal()
}
