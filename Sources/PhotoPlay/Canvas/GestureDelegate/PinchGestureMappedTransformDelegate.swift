import QuartzCore

protocol PinchGestureMappedTransformDelegate: AnyObject {
    func pinch(_ context: PinchGestureContext)
}
