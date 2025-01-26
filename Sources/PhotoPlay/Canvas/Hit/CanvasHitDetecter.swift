import QuartzCore

protocol CanvasHitDetecter: AnyObject {
    func hitSelectable(at workspacePoint: CGPoint) -> CALayer?
    func hitTransformable(at workspacePoint: CGPoint) -> CALayer?
}
