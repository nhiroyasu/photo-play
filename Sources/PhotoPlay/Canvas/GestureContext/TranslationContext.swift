import QuartzCore

enum TranslationContext {
    case relativeLayer(target: CAParentRelativeLayer, fromRelativePoint: CGPoint, gestureTranslation: CGPoint)
}
