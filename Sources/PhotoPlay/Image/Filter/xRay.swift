import CoreImage
import CoreImage.CIFilterBuiltins

func xRay(inputImage: CIImage) -> CIImage? {
    let xRayFilter = CIFilter.xRay()
    xRayFilter.inputImage = inputImage
    return xRayFilter.outputImage
}
