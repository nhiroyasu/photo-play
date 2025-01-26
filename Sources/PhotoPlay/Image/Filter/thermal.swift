import CoreImage
import CoreImage.CIFilterBuiltins

func thermal(inputImage: CIImage) -> CIImage? {
    let thermalFilter = CIFilter.thermal()
    thermalFilter.inputImage = inputImage
    return thermalFilter.outputImage
}
