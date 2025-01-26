import CoreImage
import CoreImage.CIFilterBuiltins

func sepia(inputImage: CIImage, intensity: Float) -> CIImage? {
    let sepiaFilter = CIFilter.sepiaTone()
    sepiaFilter.inputImage = inputImage
    sepiaFilter.intensity = intensity
    return sepiaFilter.outputImage
}
