import QuartzCore

protocol CanvasTransformChanger: AnyObject {
    func onChange(to transform: CATransform3D, immediate: Bool)
}
