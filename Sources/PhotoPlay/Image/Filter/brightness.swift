import CoreImage
import CoreImage.CIFilterBuiltins

func brightness(inputImage: CIImage, amount: Float) -> CIImage? {
    let brightnessFilter = CIFilter.colorControls()
    brightnessFilter.inputImage = inputImage
    brightnessFilter.brightness = amount
    return brightnessFilter.outputImage
}
