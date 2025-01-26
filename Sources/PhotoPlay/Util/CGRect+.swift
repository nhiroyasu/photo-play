import QuartzCore

extension CGRect {
    func contains(_ rect: CGRect) -> Bool {
        contains(rect.origin) && contains(CGPoint(x: rect.maxX, y: rect.maxY))
    }

    func transform(with transform: CATransform3D, coordinate: CGPoint = .zero) -> CGRect {
        transformRect(self, with: transform, coordinate: coordinate)
    }

    func path() -> CGPath {
        let path = CGMutablePath()
        path.addRect(self)
        return path
    }
}

extension CGSize {
    func transform(with transform: CATransform3D) -> CGSize {
        transformSize(self, with: transform)
    }

    func scale(by scale: CGFloat) -> CGSize {
        CGSize(width: width * scale, height: height * scale)
    }

    func path() -> CGPath {
        let path = CGMutablePath()
        path.addRect(CGRect(origin: .zero, size: self))
        return path
    }
}
