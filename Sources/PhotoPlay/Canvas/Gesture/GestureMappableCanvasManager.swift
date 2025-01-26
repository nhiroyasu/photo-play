public protocol GestureMappableCanvasManager {
    func panGestureMapper() -> CanvasPanGestureMappable
    func pinchGestureMapper() -> CanvasPinchGestureMappable
    func rotationGestureMapper() -> CanvasRotationGestureMappable
    func tapGestureMapper() -> CanvasTapGestureMappable
    func rawTouchMapper() -> CanvasRawTouchMappable
}
