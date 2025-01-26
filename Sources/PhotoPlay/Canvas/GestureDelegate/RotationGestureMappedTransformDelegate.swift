import QuartzCore

protocol RotationGestureMappedTransformDelegate: AnyObject {
    func rotate(_ context: RotationGestureContext)
}
