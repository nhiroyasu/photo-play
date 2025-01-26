import QuartzCore

enum CropContext {
    case transform(fromTransform: CATransform3D, concatTransform: CATransform3D)
    case crop(origin: CropOrigin, fromCropFrame: CGRect, toCropFrame: CGRect)

    enum CropOrigin {
        case leftTop
        case leftBottom
        case rightTop
        case rightBottom
    }
}
