import QuartzCore

protocol CanvasCoordinateConvertable: AnyObject {
    func convert(workspacePoint: CGPoint, to layer: CALayer) -> CGPoint
}
