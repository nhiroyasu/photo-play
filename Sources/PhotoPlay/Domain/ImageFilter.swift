import Foundation

public enum ImageFilter: Hashable {
    case noFilter
    case brightness(amount: Float)
    case contrast(amount: Float)
    case saturation(amount: Float)
    case temperature(amount: CGFloat)
    case sharpen(radius: Float, sharpness: Float)
    case vignette(intensity: Float, radius: Float)
    case sepia(intensity: Float)

    case chrome
    case fade
    case process
    case transfer
    case instant
    case mono
    case noir
    case tonal
    case thermal
    case xRay

    case bokenBlur
}
