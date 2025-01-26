import CoreImage
import CoreImage.CIFilterBuiltins

func fade(inputImage: CIImage) -> CIImage? {
    let fadeFilter = CIFilter.photoEffectFade()
    fadeFilter.inputImage = inputImage
    return fadeFilter.outputImage
}
