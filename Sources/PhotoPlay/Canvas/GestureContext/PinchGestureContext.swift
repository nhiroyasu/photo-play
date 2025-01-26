import QuartzCore

enum PinchGestureContext {
    case relativeLayer(target: CAParentRelativeLayer, fromScale: CGSize, gestureScale: CGFloat)
}
