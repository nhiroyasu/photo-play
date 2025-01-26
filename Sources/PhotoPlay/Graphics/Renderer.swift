import QuartzCore

public class Renderer {
    public func render(
        for layer: CALayer,
        width: Int,
        height: Int,
        quality: CGInterpolationQuality = .default
    ) -> RenderingContext? {
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 4 * width,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        context.interpolationQuality = quality

        // Reverse the Y-axis coordinate
        let widthScaleRatio = CGFloat(width) / layer.bounds.width
        let heightScaleRatio = CGFloat(height) / layer.bounds.height
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: widthScaleRatio, y: -heightScaleRatio)

        // Apply the transform considering the anchor point and position
//        let positionTransform = CATransform3DMakeTranslation(
//            layer.position.x - layer.transformedAnchorPosition.x,
//            layer.position.y - layer.transformedAnchorPosition.y,
//            0
//        )
//        let transform = CATransform3DConcat(layer.transform, positionTransform)
//        let anchorX = layer.bounds.width * layer.anchorPoint.x
//        let anchorY = layer.bounds.height * layer.anchorPoint.y
//        context.translateBy(x: anchorX, y: anchorY)
//        context.concatenate(CATransform3DGetAffineTransform(transform))
//        context.translateBy(x: -anchorX, y: -anchorY)

        layer.render(in: context)
        return RenderingContext(cgContext: context)
    }
}
