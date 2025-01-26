import UIKit
import Combine
import PhotoPlay

public class PhotoPlayCanvasView: UIView {
    private let canvasManager: CAImageCanvasManager
    private let gestureEffecter: UICanvasGestureEffecter
    private let rawTouchEffecter: UICanvasRawTouchEffecter

    private var panGesture: UIPanGestureRecognizer!
    private var pinchGesture: UIPinchGestureRecognizer!
    private var rotateGesture: UIRotationGestureRecognizer!
    private var tapGesture: UITapGestureRecognizer!

    private var cancellable: Set<AnyCancellable> = []

    public init(frame: CGRect, canvasManager: CAImageCanvasManager) {
        self.canvasManager = canvasManager
        self.gestureEffecter = UICanvasGestureEffecter(canvasManager: canvasManager)
        self.rawTouchEffecter = UICanvasRawTouchEffecter(canvasManager: canvasManager)
        super.init(frame: frame)

        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        addGestureRecognizer(panGesture)
        pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture))
        addGestureRecognizer(pinchGesture)
        rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture))
        addGestureRecognizer(rotateGesture)
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        addGestureRecognizer(tapGesture)

        observeCanvasOperation()
    }

    public override func layoutSublayers(of layer: CALayer) {
        canvasManager.display(in: layer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        gestureEffecter.pan(gesture)
    }

    @objc func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        gestureEffecter.pinch(gesture)
    }

    @objc func handleRotationGesture(_ gesture: UIRotationGestureRecognizer) {
        gestureEffecter.rotation(gesture)
    }

    @objc func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        gestureEffecter.tap(gesture)
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        rawTouchEffecter.began(touches, with: event)
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        rawTouchEffecter.move(touches, with: event)
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        rawTouchEffecter.ended(touches, with: event)
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        rawTouchEffecter.cancelled(touches, with: event)
    }

    private func observeCanvasOperation() {
        canvasManager
            .operationPublisher()
            .sink { [weak self] newOperation in
                guard let self else { return }
                switch newOperation {
                case .select, .crop:
                    panGesture.isEnabled = true
                    pinchGesture.isEnabled = true
                    rotateGesture.isEnabled = true
                    tapGesture.isEnabled = true
                case .pen, .erase:
                    panGesture.isEnabled = false
                    pinchGesture.isEnabled = false
                    rotateGesture.isEnabled = false
                    tapGesture.isEnabled = false
                }
            }
            .store(in: &cancellable)
    }
}
