import CoreImage
import CoreImage.CIFilterBuiltins

func transfer(inputImage: CIImage) -> CIImage? {
    let transferFilter = CIFilter.photoEffectTransfer()
    transferFilter.inputImage = inputImage
    return transferFilter.outputImage
}
