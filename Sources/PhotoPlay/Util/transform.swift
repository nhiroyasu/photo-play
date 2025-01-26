import QuartzCore

func transformPoint(_ point: CGPoint, with transform: CATransform3D) -> CGPoint {
    let x = point.x
    let y = point.y
    let z: CGFloat = 0.0

    // NOTE: When calculated as is, the Z-axis rotation direction of CALayer.transform gets reversed, so I applied a negative sign to m12 and m21.
    // But if one scale is reversed, you need to further invert the Y-axis (i.e., invertYForCA will be 1)
    let invertYForCA: CGFloat
    if transform.m11 == .zero, transform.m22 == .zero {
        // pi/2 or -pi/2 rotation case, m11 and m22 is zero.
        // In this case, the inversion of the Y-axis is determined by the product of the signs of m12 and m21
        invertYForCA = transform.m12.sign.multiplier * transform.m21.sign.multiplier
    } else {
        invertYForCA = -(transform.m11.sign.multiplier * transform.m22.sign.multiplier) // I don't know if I should calculate m33 and m44
    }
    let transformedX = transform.m11 * x + transform.m12 * y * invertYForCA + transform.m13 * z + transform.m14 + transform.m41
    let transformedY = transform.m21 * x * invertYForCA + transform.m22 * y + transform.m23 * z + transform.m24 + transform.m42
    // let transformedZ = transform.m31 * x + transform.m32 * y + transform.m33 * z + transform.m34 + transform.m43

    return CGPoint(x: transformedX, y: transformedY)
}

func transformPoint(_ point: CGPoint, with transform: CATransform3D, originOffset: CGPoint) -> CGPoint {
    let appliedOffsetPoint = CGPoint(
        x: point.x - originOffset.x,
        y: point.y - originOffset.y
    )
    let transformedPoint = transformPoint(appliedOffsetPoint, with: transform)
    return CGPoint(
        x: transformedPoint.x + originOffset.x,
        y: transformedPoint.y + originOffset.y
    )
}

func transformSize(_ size: CGSize, with transform: CATransform3D) -> CGSize {
    let width = size.width
    let height = size.height
    let transformedWidth = transform.m11 * width + transform.m12 * height
    let transformedHeight = transform.m21 * width + transform.m22 * height
    return CGSize(width: transformedWidth, height: transformedHeight)
}

func transformRect(_ rect: CGRect, with transform: CATransform3D) -> CGRect {
    let leftTopPoint = CGPoint(x: rect.minX, y: rect.minY)
    let rightTopPoint = CGPoint(x: rect.maxX, y: rect.minY)
    let leftBottomPoint = CGPoint(x: rect.minX, y: rect.maxY)
    let rightBottomPoint = CGPoint(x: rect.maxX, y: rect.maxY)
    let transformedLeftTopPoint = transformPoint(leftTopPoint, with: transform)
    let transformedRightTopPoint = transformPoint(rightTopPoint, with: transform)
    let transformedLeftBottomPoint = transformPoint(leftBottomPoint, with: transform)
    let transformedRightBottomPoint = transformPoint(rightBottomPoint, with: transform)
    let minX = min(
        transformedLeftTopPoint.x,
        transformedRightTopPoint.x,
        transformedLeftBottomPoint.x,
        transformedRightBottomPoint.x
    )
    let maxX = max(
        transformedLeftTopPoint.x,
        transformedRightTopPoint.x,
        transformedLeftBottomPoint.x,
        transformedRightBottomPoint.x
    )
    let minY = min(
        transformedLeftTopPoint.y,
        transformedRightTopPoint.y,
        transformedLeftBottomPoint.y,
        transformedRightBottomPoint.y
    )
    let maxY = max(
        transformedLeftTopPoint.y,
        transformedRightTopPoint.y,
        transformedLeftBottomPoint.y,
        transformedRightBottomPoint.y
    )
    return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
}

func transformRectToPath(_ rect: CGRect, with transform: CATransform3D) -> CGPath {
    let leftTopPoint = CGPoint(x: rect.minX, y: rect.minY)
    let rightTopPoint = CGPoint(x: rect.maxX, y: rect.minY)
    let leftBottomPoint = CGPoint(x: rect.minX, y: rect.maxY)
    let rightBottomPoint = CGPoint(x: rect.maxX, y: rect.maxY)
    let transformedLeftTopPoint = transformPoint(leftTopPoint, with: transform)
    let transformedRightTopPoint = transformPoint(rightTopPoint, with: transform)
    let transformedLeftBottomPoint = transformPoint(leftBottomPoint, with: transform)
    let transformedRightBottomPoint = transformPoint(rightBottomPoint, with: transform)
    let path = CGMutablePath()
    path.move(to: transformedLeftTopPoint)
    path.addLine(to: transformedRightTopPoint)
    path.addLine(to: transformedRightBottomPoint)
    path.addLine(to: transformedLeftBottomPoint)
    path.closeSubpath()
    return path
}

func transformRect(_ rect: CGRect, with transform: CATransform3D, coordinate: CGPoint) -> CGRect {
    let originAnchorPointRect = CGRect(
        x: rect.origin.x - coordinate.x,
        y: rect.origin.y - coordinate.y,
        width: rect.size.width,
        height: rect.size.height
    )
    let transformedRect = transformRect(originAnchorPointRect, with: transform)

    return CGRect(
        x: transformedRect.origin.x + coordinate.x,
        y: transformedRect.origin.y + coordinate.y,
        width: transformedRect.size.width,
        height: transformedRect.size.height
    )
}

func removeTranslation(for transform: CATransform3D) -> CATransform3D {
    return CATransform3D(
        m11: transform.m11, m12: transform.m12, m13: transform.m13, m14: 0,
        m21: transform.m21, m22: transform.m22, m23: transform.m23, m24: 0,
        m31: transform.m31, m32: transform.m32, m33: transform.m33, m34: 0,
        m41: 0, m42: 0, m43: 0, m44: 1
    )
}

func anchorPoint(at position: CGPoint, in frame: CGRect, with transform: CATransform3D) -> CGPoint {
    let translationForNormalize = CATransform3DMakeTranslation(-frame.midX, -frame.midY, 0)
    let normalizedAnchorPosition = transformPoint(position, with: translationForNormalize)
    let untransformedAnchorPosition = transformPoint(normalizedAnchorPosition, with: CATransform3DInvert(transform))
    let bounds = transformRect(frame, with: CATransform3DInvert(transform))

    let baseBoundsOrigin = CGPoint(x: -bounds.width / 2.0, y: -bounds.height / 2.0)
    return CGPoint(
        x: (untransformedAnchorPosition.x - baseBoundsOrigin.x) / bounds.width,
        y: (untransformedAnchorPosition.y - baseBoundsOrigin.y) / bounds.height
    )
}

func anchorPoint(at position: CGPoint, in rect: CGRect) -> CGPoint {
    CGPoint(
        x: (position.x - rect.minX) / rect.width,
        y: (position.y - rect.minY) / rect.height
    )
}

func fillTransformIfOutBounds(
    _ rect: CGRect,
    in parentRect: CGRect
) -> CATransform3D {
    if !parentRect.contains(rect) {
        // if out of bounds, return scale transform to fit the parentRect
        let anchorPoint = anchorPoint(
            at: CGPoint(x: rect.midX, y: rect.midY),
            in: parentRect
        )

        let outMinXScale = (parentRect.minX - rect.minX) / (parentRect.width * anchorPoint.x)
        let outMinYScale = (parentRect.minY - rect.minY) / (parentRect.height * anchorPoint.y)
        let outMaxXScale = (rect.maxX - parentRect.maxX) / (parentRect.width * (1.0 - anchorPoint.x))
        let outMaxYScale = (rect.maxY - parentRect.maxY) / (parentRect.height * (1.0 - anchorPoint.y))
        let exScale = 1 + max(outMinXScale, outMinYScale, outMaxXScale, outMaxYScale, 0)

        return CATransform3DMakeScale(exScale, exScale, 1)
    } else {
        return CATransform3DIdentity
    }
}
