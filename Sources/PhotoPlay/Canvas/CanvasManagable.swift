import QuartzCore
import Combine

public protocol CanvasManager {
    // Set up
    func display(in layer: CALayer)

    // Canvas
    func resizeCanvas(size: CGSize)

    // Rendering
    func render() -> RenderingContext?
}
