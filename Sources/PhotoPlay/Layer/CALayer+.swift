import QuartzCore
import UniformTypeIdentifiers
import ImageIO

extension CALayer {
    func setFixedAnchor(at gestureLocation: CGPoint) {
        let translationForNormalize = CATransform3DMakeTranslation(-frame.midX, -frame.midY, 0)
        let normalizedAnchorPosition = transformPoint(gestureLocation, with: translationForNormalize)
        let untransformedAnchorPosition = transformPoint(normalizedAnchorPosition, with: CATransform3DInvert(transform))

        let baseBoundsOrigin = CGPoint(x: -bounds.width / 2.0, y: -bounds.height / 2.0)
        self.anchorPoint = CGPoint(
            x: (untransformedAnchorPosition.x - baseBoundsOrigin.x) / bounds.width,
            y: (untransformedAnchorPosition.y - baseBoundsOrigin.y) / bounds.height
        )
        self.position = gestureLocation
    }

    /// Return a CGPoint corresponding to the anchorPoint after applying the transform. The position is not taken into consideration.
    public var transformedAnchorPosition: CGPoint {
        let anchorPositionOnBounds = CGPoint(x: bounds.width * anchorPoint.x, y: bounds.height * anchorPoint.y)
        let baseAnchorPosition = transformPoint(anchorPositionOnBounds, with: CATransform3DMakeTranslation(-bounds.midX, -bounds.midY, 0))
        let transformedAnchorPosition = transformPoint(baseAnchorPosition, with: transform)
        let transformedAnchorPositionOnBounds = transformPoint(transformedAnchorPosition, with: CATransform3DMakeTranslation(anchorPositionOnBounds.x, anchorPositionOnBounds.y, 0))
        return transformedAnchorPositionOnBounds
    }

    public func containsConsideringTransform(_ position: CGPoint) -> Bool {
        let normalizedPosition = transformPoint(position, with: CATransform3DMakeTranslation(-frame.midX, -frame.midY, 0))
        let untransformedPosition = transformPoint(normalizedPosition, with: CATransform3DInvert(transform))

        let normalizedBounds = CGRect(
            origin: .init(x: -bounds.width / 2.0, y: -bounds.height / 2.0),
            size: bounds.size
        )
        return normalizedBounds.contains(untransformedPosition)
    }

    public func getFramePath() -> CGPath {
        let normalizedBounds = CGRect(
            origin: .init(
                x: -bounds.width * anchorPoint.x,
                y: -bounds.height * anchorPoint.y
            ),
            size: bounds.size
        )
        let positionTransform = CATransform3DMakeTranslation(position.x, position.y, 0.0)
        let transformWithPosition = CATransform3DConcat(transform, positionTransform)
        return transformRectToPath(normalizedBounds, with: transformWithPosition)
    }

    public func getBoundsPath() -> CGPath {
        return transformRectToPath(bounds, with: CATransform3DIdentity)
    }

    public var framePoints: RectPoints {
        let rectPoints = RectPoints(rect: bounds)

        return rectPoints.transform(
            with: transform,
            coordinate: position
        )
    }

    public func setFrameIgnoreTransform(_ frame: CGRect) {
        self.transform = CATransform3DIdentity
        self.frame = frame
    }
}
