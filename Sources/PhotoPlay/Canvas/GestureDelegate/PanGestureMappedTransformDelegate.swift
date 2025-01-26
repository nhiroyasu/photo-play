import QuartzCore

protocol PanGestureMappedTransformDelegate: AnyObject {
    func pan(_ context: TranslationContext)
}
