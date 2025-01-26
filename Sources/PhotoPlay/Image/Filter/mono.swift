import CoreImage
import CoreImage.CIFilterBuiltins

func mono(inputImage: CIImage) -> CIImage? {
    let monoFilter = CIFilter.photoEffectMono()
    monoFilter.inputImage = inputImage
    return monoFilter.outputImage
}
