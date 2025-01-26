import UIKit
import PhotoPlay

class UICanvasRawTouchEffecter: CanvasRawTouchEffecter {
    private let canvasManager: RawTouchMappableCanvasManager

    public init(
        canvasManager: RawTouchMappableCanvasManager
    ) {
        self.canvasManager = canvasManager
    }

    var rawTouchMapper: CanvasRawTouchMappable?
    public func began(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, touches.count == 1 else { return }
        rawTouchMapper = canvasManager.rawTouchMapper()
        rawTouchMapper?.began(touch.location(in: touch.view))
    }

    public func move(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        rawTouchMapper?.move(touch.location(in: touch.view))
    }

    public func ended(_ touches: Set<UITouch>, with event: UIEvent?) {
        rawTouchMapper?.end()
        rawTouchMapper = nil
    }

    public func cancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        rawTouchMapper?.cancel()
        rawTouchMapper = nil
    }
}
