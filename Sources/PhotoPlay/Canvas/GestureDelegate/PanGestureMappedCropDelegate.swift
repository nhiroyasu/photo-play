import QuartzCore

protocol PanGestureMappedCropDelegate: AnyObject {
    func beganCropping()
    func changeCropping(fromCropFrame: CGRect, toCropFrame: CGRect)
    func endCropping(fromCropFrame: CGRect, toLayerFrame: CGRect)
}
