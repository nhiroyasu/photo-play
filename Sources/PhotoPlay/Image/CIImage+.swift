import CoreImage

public extension CIImage {
    func applyingFilter(_ filter: ImageFilter) -> CIImage {
        switch filter {
        case .noFilter:
            return self
        case .brightness(let amount):
            return brightness(inputImage: self, amount: amount) ?? self
        case .contrast(let amount):
            return contrast(inputImage: self, amount: amount) ?? self
        case .saturation(let amount):
            return saturation(inputImage: self, amount: amount) ?? self
        case .temperature(let amount):
            return temperature(inputImage: self, amount: amount) ?? self
        case .sharpen(let radius, let sharpness):
            return sharpen(inputImage: self, radius: radius, sharpness: sharpness) ?? self
        case .vignette(intensity: let intensity, radius: let radius):
            return vignette(inputImage: self, intensity: intensity, radius: radius) ?? self
        case .sepia(intensity: let intensity):
            return sepia(inputImage: self, intensity: intensity) ?? self

        case .chrome:
            return chrome(inputImage: self) ?? self
        case .fade:
            return fade(inputImage: self) ?? self
        case .tonal:
            return tonal(inputImage: self) ?? self
        case .process:
            return process(inputImage: self) ?? self
        case .transfer:
            return transfer(inputImage: self) ?? self
        case .instant:
            return instant(inputImage: self) ?? self
        case .mono:
            return mono(inputImage: self) ?? self
        case .noir:
            return noir(inputImage: self) ?? self
        case .thermal:
            return thermal(inputImage: self) ?? self
        case .xRay:
            return xRay(inputImage: self) ?? self

        case .bokenBlur:
            return bokenBlur(inputImage: self) ?? self
        }
    }

    func applyingFilters(_ filters: [ImageFilter]) -> CIImage {
        filters.reduce(self) { $0.applyingFilter($1) }
    }
}
