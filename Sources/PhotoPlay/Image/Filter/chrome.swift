import CoreImage
import CoreImage.CIFilterBuiltins

func chrome(inputImage: CIImage) -> CIImage? {
    let chromeFilter = CIFilter.photoEffectChrome()
    chromeFilter.inputImage = inputImage
    return chromeFilter.outputImage
}
