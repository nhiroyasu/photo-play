import CoreImage
import CoreImage.CIFilterBuiltins

func sharpen(inputImage: CIImage, radius: Float, sharpness: Float) -> CIImage? {
    let sharpenLuminance = CIFilter.sharpenLuminance()
    sharpenLuminance.inputImage = inputImage
    sharpenLuminance.radius = radius
    sharpenLuminance.sharpness = sharpness
    return sharpenLuminance.outputImage
}
