import CoreImage
import CoreImage.CIFilterBuiltins

func bokenBlur(inputImage: CIImage) -> CIImage? {
    let bokehBlurFilter = CIFilter.bokehBlur()
    bokehBlurFilter.inputImage = inputImage
    bokehBlurFilter.ringSize = 0.1
    bokehBlurFilter.ringAmount = 0
    bokehBlurFilter.softness = 1
    bokehBlurFilter.radius = 20
    return bokehBlurFilter.outputImage
}
