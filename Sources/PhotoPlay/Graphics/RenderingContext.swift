import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

public class RenderingContext {
    let cgContext: CGContext

    init(cgContext: CGContext) {
        self.cgContext = cgContext
    }

    public func pngImage() -> Data? {
        guard let cgImage = cgContext.makeImage() else { return nil }
        let data = NSMutableData()
        guard let imageDestination = CGImageDestinationCreateWithData(data, UTType.png.identifier as CFString, 1, nil) else {
            return nil
        }

        CGImageDestinationAddImage(imageDestination, cgImage, nil)

        if CGImageDestinationFinalize(imageDestination) {
            return data as Data
        } else {
            return nil
        }
    }

    public func jpegImage(quality: CGFloat) -> Data? {
        guard let cgImage = cgContext.makeImage() else { return nil }
        let data = NSMutableData()
        guard let imageDestination = CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil) else {
            return nil
        }

        let options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: quality
        ]
        CGImageDestinationAddImage(imageDestination, cgImage, options as CFDictionary)

        if CGImageDestinationFinalize(imageDestination) {
            return data as Data
        } else {
            return nil
        }
    }

    public func tiffImage() -> Data? {
        guard let cgImage = cgContext.makeImage() else { return nil }
        let data = NSMutableData()
        guard let imageDestination = CGImageDestinationCreateWithData(data, UTType.tiff.identifier as CFString, 1, nil) else {
            return nil
        }

        CGImageDestinationAddImage(imageDestination, cgImage, nil)

        if CGImageDestinationFinalize(imageDestination) {
            return data as Data
        } else {
            return nil
        }
    }

    public func cgImage() -> CGImage? {
        cgContext.makeImage()
    }
}
