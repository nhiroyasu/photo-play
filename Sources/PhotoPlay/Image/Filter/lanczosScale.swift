import CoreImage
import CoreImage.CIFilterBuiltins

func lanczosScale(inputImage: CIImage, scale: CGFloat) -> CIImage? {
    let lanczosScaleFilter = CIFilter.lanczosScaleTransform()
    lanczosScaleFilter.inputImage = inputImage
    lanczosScaleFilter.scale = Float(scale)
    lanczosScaleFilter.aspectRatio = 1
    return lanczosScaleFilter.outputImage
}

public extension CIImage {
    func lanczosScaled(scale: CGFloat) -> CIImage {
        lanczosScale(inputImage: self, scale: scale) ?? self
    }
}
