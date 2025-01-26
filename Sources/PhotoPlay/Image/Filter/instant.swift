import CoreImage
import CoreImage.CIFilterBuiltins

func instant(inputImage: CIImage) -> CIImage? {
    let instantFilter = CIFilter.photoEffectInstant()
    instantFilter.inputImage = inputImage
    return instantFilter.outputImage
}
