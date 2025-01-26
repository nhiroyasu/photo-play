import CoreImage
import CoreImage.CIFilterBuiltins

func saturation(inputImage: CIImage, amount: Float) -> CIImage? {
    let saturationFilter = CIFilter.colorControls()
    saturationFilter.inputImage = inputImage
    saturationFilter.saturation = amount
    return saturationFilter.outputImage
}
