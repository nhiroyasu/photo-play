import QuartzCore

extension CAImageCanvasManager: CanvasHitDetecter {
    func hitSelectable(at workspacePoint: CGPoint) -> CALayer? {
        let canvasPoint = self.convert(workspacePoint: workspacePoint, to: overlayContainerLayer)
        return overlayContainerLayer.hitSelectable(at: canvasPoint)
    }

    func hitTransformable(at workspacePoint: CGPoint) -> CALayer? {
        let canvasPoint = self.convert(workspacePoint: workspacePoint, to: overlayContainerLayer)
        return overlayContainerLayer.hitTransformable(at: canvasPoint)
    }
}
