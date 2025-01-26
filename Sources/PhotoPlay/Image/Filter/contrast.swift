import CoreImage
import CoreImage.CIFilterBuiltins

func contrast(inputImage: CIImage, amount: Float) -> CIImage? {
    let contrastFilter = CIFilter.colorControls()
    let hoge = CIFilter.sharpenLuminance()
    hoge.setDefaults()
    contrastFilter.inputImage = inputImage
    contrastFilter.contrast = amount
    return contrastFilter.outputImage
}
