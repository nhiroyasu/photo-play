import QuartzCore

enum TranslationContext {
    case relativeLayer(target: CAParentRelativeLayer, fromWorkspacePosition: CGPoint, gestureTranslation: CGPoint)
}
