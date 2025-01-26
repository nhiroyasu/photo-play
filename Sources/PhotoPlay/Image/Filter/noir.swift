import CoreImage
import CoreImage.CIFilterBuiltins

func noir(inputImage: CIImage) -> CIImage? {
    let noirFilter = CIFilter.photoEffectNoir()
    noirFilter.inputImage = inputImage
    return noirFilter.outputImage
}
