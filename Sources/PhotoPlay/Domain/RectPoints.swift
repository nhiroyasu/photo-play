import Foundation
import QuartzCore

public struct RectPoints {
    public let minX_minY: CGPoint
    public let maxX_minY: CGPoint
    public let minX_maxY: CGPoint
    public let maxX_maxY: CGPoint

    public init(minX_minY: CGPoint, maxX_minY: CGPoint, minX_maxY: CGPoint, maxX_maxY: CGPoint) {
        self.minX_minY = minX_minY
        self.maxX_minY = maxX_minY
        self.minX_maxY = minX_maxY
        self.maxX_maxY = maxX_maxY
    }

    public init(rect: CGRect) {
        minX_minY = CGPoint(x: rect.minX, y: rect.minY)
        maxX_minY = CGPoint(x: rect.maxX, y: rect.minY)
        minX_maxY = CGPoint(x: rect.minX, y: rect.maxY)
        maxX_maxY = CGPoint(x: rect.maxX, y: rect.maxY)
    }

    public var cgRect: CGRect {
        let minX = min(minX_minY.x, maxX_minY.x, minX_maxY.x, maxX_maxY.x)
        let maxX = max(minX_minY.x, maxX_minY.x, minX_maxY.x, maxX_maxY.x)
        let minY = min(minX_minY.y, maxX_minY.y, minX_maxY.y, maxX_maxY.y)
        let maxY = max(minX_minY.y, maxX_minY.y, minX_maxY.y, maxX_maxY.y)
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    public func transform(with transform: CATransform3D) -> RectPoints {
        let minX_minY = transformPoint(self.minX_minY, with: transform)
        let maxX_minY = transformPoint(self.maxX_minY, with: transform)
        let minX_maxY = transformPoint(self.minX_maxY, with: transform)
        let maxX_maxY = transformPoint(self.maxX_maxY, with: transform)
        return RectPoints(
            minX_minY: minX_minY,
            maxX_minY: maxX_minY,
            minX_maxY: minX_maxY,
            maxX_maxY: maxX_maxY
        )
    }

    public func transform(with transform: CATransform3D, coordinate: CGPoint) -> RectPoints {
        let arranged_minX_minY = CGPoint(x: minX_minY.x - coordinate.x, y: minX_minY.y - coordinate.y)
        let arranged_maxX_minY = CGPoint(x: maxX_minY.x - coordinate.x, y: maxX_minY.y - coordinate.y)
        let arranged_minX_maxY = CGPoint(x: minX_maxY.x - coordinate.x, y: minX_maxY.y - coordinate.y)
        let arranged_maxX_maxY = CGPoint(x: maxX_maxY.x - coordinate.x, y: maxX_maxY.y - coordinate.y)

        let minX_minY = transformPoint(arranged_minX_minY, with: transform)
        let maxX_minY = transformPoint(arranged_maxX_minY, with: transform)
        let minX_maxY = transformPoint(arranged_minX_maxY, with: transform)
        let maxX_maxY = transformPoint(arranged_maxX_maxY, with: transform)

        let reversed_minX_minY = CGPoint(x: minX_minY.x + coordinate.x, y: minX_minY.y + coordinate.y)
        let reversed_maxX_minY = CGPoint(x: maxX_minY.x + coordinate.x, y: maxX_minY.y + coordinate.y)
        let reversed_minX_maxY = CGPoint(x: minX_maxY.x + coordinate.x, y: minX_maxY.y + coordinate.y)
        let reversed_maxX_maxY = CGPoint(x: maxX_maxY.x + coordinate.x, y: maxX_maxY.y + coordinate.y)

        return RectPoints(
            minX_minY: reversed_minX_minY,
            maxX_minY: reversed_maxX_minY,
            minX_maxY: reversed_minX_maxY,
            maxX_maxY: reversed_maxX_maxY
        )
    }
}
