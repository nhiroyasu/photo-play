import QuartzCore

protocol EditableContainerLayer {
    typealias Layer = any CALayer & EditableLayer

    func hitTransformable(at position: CGPoint) -> Layer?
    func hitSelectable(at position: CGPoint) -> Layer?
}
