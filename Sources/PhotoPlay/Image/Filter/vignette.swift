import CoreImage
import CoreImage.CIFilterBuiltins

func vignette(inputImage: CIImage, intensity: Float, radius: Float) -> CIImage? {
    let vignetteFilter = CIFilter.vignette()
    vignetteFilter.inputImage = inputImage
    vignetteFilter.intensity = intensity
    vignetteFilter.radius = radius
    return vignetteFilter.outputImage
}
