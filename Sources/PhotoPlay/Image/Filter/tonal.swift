import CoreImage
import CoreImage.CIFilterBuiltins

func tonal(inputImage: CIImage) -> CIImage? {
    let tonalFilter = CIFilter.photoEffectTonal()
    tonalFilter.inputImage = inputImage
    return tonalFilter.outputImage
}
