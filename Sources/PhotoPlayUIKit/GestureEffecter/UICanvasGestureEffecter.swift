import UIKit
import PhotoPlay

class UICanvasGestureEffecter: CanvasGestureEffecter {
    private let canvasManager: GestureMappableCanvasManager

    init(
        canvasManager: GestureMappableCanvasManager
    ) {
        self.canvasManager = canvasManager
    }

    // MARK: - Handle Gestures

    var panGestureMapper: CanvasPanGestureMappable?
    public func pan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            panGestureMapper = canvasManager.panGestureMapper()
            panGestureMapper?.began(gesture.location(in: gesture.view))
        case .changed:
            panGestureMapper?.move(gesture.translation(in: gesture.view))
        case .ended, .cancelled, .failed:
            panGestureMapper?.end()
            panGestureMapper = nil
        default: break
        }
    }

    var pinchGestureMapper: CanvasPinchGestureMappable?
    public func pinch(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            pinchGestureMapper = canvasManager.pinchGestureMapper()
            pinchGestureMapper?.began(gesture.location(in: gesture.view))
        case .changed:
            pinchGestureMapper?.pinch(gesture.scale)
        case .ended, .cancelled, .failed:
            pinchGestureMapper?.end()
            pinchGestureMapper = nil
        default: break
        }
    }

    var rotationGestureMapper: CanvasRotationGestureMappable?
    public func rotation(_ gesture: UIRotationGestureRecognizer) {
        switch gesture.state {
        case .began:
            rotationGestureMapper = canvasManager.rotationGestureMapper()
            rotationGestureMapper?.began(gesture.location(in: gesture.view))
        case .changed:
            rotationGestureMapper?.rotate(gesture.rotation)
        case .ended, .cancelled, .failed:
            rotationGestureMapper?.end()
            rotationGestureMapper = nil
        default: break
        }
    }

    public func tap(_ gesture: UITapGestureRecognizer) {
        let tapGestureMapper = canvasManager.tapGestureMapper()

        tapGestureMapper.tap(gesture.location(in: gesture.view))
    }
}
