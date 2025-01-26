import CoreImage
import CoreImage.CIFilterBuiltins

func temperature(inputImage: CIImage, amount: CGFloat) -> CIImage? {
    let temperatureFilter = CIFilter.temperatureAndTint()
    temperatureFilter.inputImage = inputImage
    temperatureFilter.neutral = CIVector(x: 6500)
    temperatureFilter.targetNeutral = CIVector(x: amount)
    return temperatureFilter.outputImage
}
