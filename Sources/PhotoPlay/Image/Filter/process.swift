import CoreImage
import CoreImage.CIFilterBuiltins

func process(inputImage: CIImage) -> CIImage? {
    let processFilter = CIFilter.photoEffectProcess()
    processFilter.inputImage = inputImage
    return processFilter.outputImage
}
