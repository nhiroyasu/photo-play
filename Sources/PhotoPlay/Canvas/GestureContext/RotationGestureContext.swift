import QuartzCore

enum RotationGestureContext {
    case relativeLayer(target: CAParentRelativeLayer, fromRotation: CGFloat, gestureRotation: CGFloat)
}
