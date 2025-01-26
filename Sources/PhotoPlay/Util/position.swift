import CoreGraphics

public struct EdgeInset {
    public let top: CGFloat
    public let left: CGFloat
    public let bottom: CGFloat
    public let right: CGFloat

    public init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }

    public init(vertical: CGFloat, horizontal: CGFloat) {
        self.top = vertical
        self.left = horizontal
        self.bottom = vertical
        self.right = horizontal
    }

    public init(all: CGFloat) {
        self.top = all
        self.left = all
        self.bottom = all
        self.right = all
    }
}

public func fitFrame(
    target size: CGSize,
    to parentSize: CGSize,
    padding: EdgeInset = EdgeInset(all: 0)
) -> CGRect {
    let aspectRatio = CGFloat(size.width) / CGFloat(size.height)
    let parentAspectRatio = parentSize.width / parentSize.height
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
    if aspectRatio > parentAspectRatio {
        width = parentSize.width - padding.left - padding.right
        height = width / aspectRatio
        x = padding.left
        y = (parentSize.height - height - padding.top - padding.bottom) / 2
    } else {
        height = parentSize.height - padding.top - padding.bottom
        width = height * aspectRatio
        x = (parentSize.width - width - padding.left - padding.right) / 2
        y = padding.top
    }
    return CGRect(x: x, y: y, width: width, height: height)
}

public func fillFrame(
    target size: CGSize,
    to parentSize: CGSize
) -> CGRect {
    let aspectRatio = CGFloat(size.width) / CGFloat(size.height)
    let parentAspectRatio = parentSize.width / parentSize.height
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
    if aspectRatio > parentAspectRatio {
        width = parentSize.height * aspectRatio
        height = parentSize.height
        x = (parentSize.width - width) / 2
        y = 0
    } else {
        width = parentSize.width
        height = parentSize.width / aspectRatio
        x = 0
        y = (parentSize.height - height) / 2
    }
    return CGRect(x: x, y: y, width: width, height: height)
}


public func fillFrame(
    target size: CGSize,
    to parentSize: CGSize,
    origin: CGPoint
) -> CGRect {
    let aspectRatio = CGFloat(size.width) / CGFloat(size.height)
    let parentAspectRatio = parentSize.width / parentSize.height
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
    if aspectRatio > parentAspectRatio {
        width = parentSize.height * aspectRatio
        height = parentSize.height
        x = origin.x
        y = origin.y
    } else {
        width = parentSize.width
        height = parentSize.width / aspectRatio
        x = origin.x
        y = origin.y
    }
    return CGRect(x: x, y: y, width: width, height: height)
}
