import QuartzCore
import Combine
import CoreImage

public final class CAImageCanvasManager: CACanvasManager, ImageCanvasManager {
    let image: CGImage
    let configuration: CanvasConfiguration

    let backgroundLayer: CATransparentLayer
    let selectionFrameLayer: CADrawingSelectionFrameLayer
    let croppingGuideLayer: CACroppingGuideLayer
    let imageLayer: CAImageLayer
    let paintLayer: CAPaintLayer
    let overlayContainerLayer: CAEditableContainerLayer
    let outBoundsMask = CAOutBoundsMaskLayer()

    // constants
    let croppingGuideFrameOffset: CGFloat = 4

    // variables
    var baseImageFrame: CGRect = .zero
    var transform: CATransform3D = CATransform3DIdentity
    var needsAdjustingTransform: AdjustingTransformReason?
    var needsLayoutCroppingGuide: LayoutCroppingGuideReason?
    var selectedLayers: [CALayer] = []

    public var operation: ImageCanvasOperation = .select
    let onChangeOperation: PassthroughSubject<ImageCanvasOperation, Never> = .init()
    public var pen: Pen = .gPen(color: .init(gray: 0, alpha: 1.0), size: 0.0)
    let onChangePen: PassthroughSubject<Pen, Never> = .init()

    var cancellable: Set<AnyCancellable> = []

    public init(
        with image: CGImage,
        configuration: CanvasConfiguration = .default
    ) {
        self.image = image
        self.configuration = configuration
        self.backgroundLayer = CATransparentLayer(step: 10)
        self.selectionFrameLayer = CADrawingSelectionFrameLayer()
        self.croppingGuideLayer = CACroppingGuideLayer(frameOffset: croppingGuideFrameOffset)
        self.croppingGuideLayer.isHidden = true
        imageLayer = .init(
            image: image,
            screenScale: 3, // TODO: DI
            isSelectable: false,
            isTransformable: false
        )
        paintLayer = .init(size: CGSize(width: image.width, height: image.height))
        overlayContainerLayer = .init()

        super.init(canvasSize: CGSize(width: image.width, height: image.height))

        // setup layers
        workspace.sublayers = [
            backgroundLayer,
            canvas,
            selectionFrameLayer,
            croppingGuideLayer
        ]
        workspace.delegate = self

        canvas.sublayers = [imageLayer, paintLayer, overlayContainerLayer]
        canvas.delegate = self

        selectionFrameLayer.name = PHOTO_PLAY_SELECTION_FRAME_LAYER
        selectionFrameLayer.delegate = self

        // configuration
        backgroundLayer.contentsScale = configuration.contentsScale
        selectionFrameLayer.contentsScale = configuration.contentsScale
        croppingGuideLayer.contentsScale = configuration.contentsScale
        paintLayer.contentsScale = configuration.contentsScale

        // subscription
        self.onChangePen
            .sink { [weak self] pen in
                self?.paintLayer.pen = pen
            }
            .store(in: &cancellable)
        self.onChangeOperation
            .sink { [weak self] operation in
                self?.croppingGuideLayer.isHidden = operation != .crop
            }
            .store(in: &cancellable)
        self.onChangeOperation
            .sink { [weak self] _ in
                self?.selectedLayers.removeAll()
                self?.selectionFrameLayer.setNeedsDisplay()
            }
            .store(in: &cancellable)
    }

    // MARK: - State Management

    public func setOperation(_ operation: ImageCanvasOperation) {
        self.operation = operation
        onChangeOperation.send(operation)
    }

    public func operationPublisher() -> AnyPublisher<ImageCanvasOperation, Never> {
        onChangeOperation.eraseToAnyPublisher()
    }

    public func setPen(_ pen: Pen) {
        self.pen = pen
        onChangePen.send(pen)
    }

    public func penPublisher() -> AnyPublisher<Pen, Never> {
        onChangePen.eraseToAnyPublisher()
    }

    // MARK: - Canvas

    public func resetCrop() {
        self.resizeCanvas(size: .original)
    }

    public func resizeCanvas(size: ImageSize) {
        self.transform = CATransform3DIdentity
        canvas.setNeedsLayout()

        switch size {
        case .original:
            super.resizeCanvas(size: CGSize(width: image.width, height: image.height))
        case .square:
            if image.width > image.height {
                super.resizeCanvas(size: CGSize(width: image.height, height: image.height))
            } else {
                super.resizeCanvas(size: CGSize(width: image.width, height: image.width))
            }
        case .aspect16_9:
            if image.width > image.height {
                super.resizeCanvas(size: CGSize(width: image.height * 16 / 9, height: image.height))
            } else {
                super.resizeCanvas(size: CGSize(width: image.width, height: image.width * 9 / 16))
            }
        case .aspect4_3:
            if image.width > image.height {
                super.resizeCanvas(size: CGSize(width: image.height * 4 / 3, height: image.height))
            } else {
                super.resizeCanvas(size: CGSize(width: image.width, height: image.width * 3 / 4))
            }
        }
    }

    // MARK: - Transform

    public func rotateCanvasRightAngle90() {
        let newTransform = CATransform3DConcat(
            imageLayer.transform,
            CATransform3DMakeRotation(.pi / 2, 0, 0, 1)
        )
        let canvasFrameOnImgCoord = canvas.bounds.transform(
            with: CATransform3DInvert(newTransform),
            coordinate: CGPoint(
                x: canvas.bounds.width * canvas.anchorPoint.x,
                y: canvas.bounds.height * canvas.anchorPoint.y
            )
        )
        let exTransform = fillTransformIfOutBounds(canvasFrameOnImgCoord, in: baseImageFrame)
        self.transform = CATransform3DConcat(newTransform, exTransform)
        canvas.setNeedsLayout()
    }

    public func invertVertical() {
        self.transform = CATransform3DConcat(imageLayer.transform, CATransform3DMakeScale(1, -1, 1))
        canvas.setNeedsLayout()
    }

    public func invertHorizontal() {
        self.transform = CATransform3DConcat(imageLayer.transform, CATransform3DMakeScale(-1, 1, 1))
        canvas.setNeedsLayout()
    }

    // MARK: - Image

    public func applyImageFilter(_ imageFilters: [ImageFilter], asyncRendering: Bool = true) {
        if asyncRendering {
            imageLayer.applyAsync(imageFilters: imageFilters)
        } else {
            imageLayer.apply(imageFilters: imageFilters)
        }
    }

    // MARK: - Paint

    public func setEraserSize(_ size: CGFloat) {
        paintLayer.eraserSize = size
    }

    // MARK: - Overlay Layers

    public func addText(text: String, fontName: String, fontSize: CGFloat, color: CGColor) {
        let center = CGPoint(x: canvas.bounds.midX, y: canvas.bounds.midY)
        let convertedCenter = canvas.convert(center, to: overlayContainerLayer)
        let relativePoint = CGPoint(
            x: convertedCenter.x / overlayContainerLayer.bounds.width,
            y: convertedCenter.y / overlayContainerLayer.bounds.height
        )
        let textLayer = CAParentRelativeTextLayer(
            text: text,
            fontName: fontName,
            fontSize: fontSize,
            foregroundColor: color,
            contentsScale: configuration.contentsScale,
            parentBounds: overlayContainerLayer.bounds,
            relativePoint: relativePoint
        )

        textLayer.relativeLayout(parentBounds: overlayContainerLayer.bounds)
        overlayContainerLayer.addSublayer(textLayer)
    }

    public func addImage(image: CGImage) {
        let center = CGPoint(x: canvas.bounds.midX, y: canvas.bounds.midY)
        let convertedCenter = canvas.convert(center, to: overlayContainerLayer)
        let relativePoint = CGPoint(
            x: convertedCenter.x / overlayContainerLayer.bounds.width,
            y: convertedCenter.y / overlayContainerLayer.bounds.height
        )
        let convertedFrame = canvas.convert(canvas.bounds, to: overlayContainerLayer)
        let relativeScale = if convertedFrame.width < convertedFrame.height {
            CGSize(
                width: 0.5,
                height: (overlayContainerLayer.bounds.width * 0.5) * (CGFloat(image.height) / CGFloat(image.width) / overlayContainerLayer.bounds.height)
            )
        } else {
            CGSize(
                width: (overlayContainerLayer.bounds.height * 0.5) * (CGFloat(image.width) / CGFloat(image.height) / overlayContainerLayer.bounds.width),
                height: 0.5
            )
        }
        let imageLayer = CAParentRelativeLayer(
            relativePoint: relativePoint,
            relativeScale: relativeScale,
            relativeRotation: 0
        )
        imageLayer.contentsScale = configuration.contentsScale
        imageLayer.contents = image
        imageLayer.relativeLayout(parentBounds: overlayContainerLayer.bounds)
        overlayContainerLayer.addSublayer(imageLayer)
    }

    // MARK: - Gestures

    public func panGestureMapper() -> any CanvasPanGestureMappable {
        switch operation {
        case .crop:
            let gestureMapper = PanGestureMappedCrop(
                currentTransform: self.transform,
                croppingGuideLayerFrame: croppingGuideLayer.frame,
                canvasBounds: canvas.bounds,
                baseImageFrame: baseImageFrame
            )
            gestureMapper.delegate = self
            gestureMapper.transformChanger = self
            gestureMapper.outBoundsMaskSwitcher = self
            return gestureMapper

        case .select:
            let gestureMapper = PanGestureMappedOverlayTranslation()
            gestureMapper.hitDetector = self
            gestureMapper.selectionDelegate = self
            gestureMapper.delegate = self
            return gestureMapper

        case .pen, .erase:
            return PanGestureMappedEmpty()
        }
    }

    public func pinchGestureMapper() -> any CanvasPinchGestureMappable {
        switch operation {
        case .crop:
            let gestureMapper = PinchGestureMappedCrop(
                currentTransform: self.transform,
                canvasBounds: canvas.bounds,
                baseImageFrame: baseImageFrame
            )
            gestureMapper.transformChanger = self
            gestureMapper.outBoundsMaskSwitcher = self
            return gestureMapper

        case .select:
            let gestureMapper = PinchGestureMappedOverlayTransform()
            gestureMapper.hitDetector = self
            gestureMapper.selectionDelegate = self
            gestureMapper.delegate = self
            return gestureMapper

        case .pen, .erase:
            return PinchGestureMappedEmpty()
        }
    }

    public func rotationGestureMapper() -> any CanvasRotationGestureMappable {
        switch operation {
        case .crop:
            let gestureMapper = RotationGestureMappedCrop(
                currentTransform: self.transform,
                canvasBounds: canvas.bounds,
                baseImageFrame: baseImageFrame
            )
            gestureMapper.transformChanger = self
            gestureMapper.outBoundsMaskSwitcher = self
            return gestureMapper

        case .select:
            let gestureMapper = RotationGestureMappedOverlayTransform()
            gestureMapper.hitDetecter = self
            gestureMapper.selectionDelegate = self
            gestureMapper.delegate = self
            return gestureMapper

        case .pen, .erase:
            return RotationGestureMappedEmpty()
        }
    }

    public func tapGestureMapper() -> CanvasTapGestureMappable {
        switch operation {
        case .select:
            let gestureMapper = TapGestureMappedSelection()
            gestureMapper.selectionDelegate = self
            gestureMapper.hitDetecter = self
            return gestureMapper

        case .pen, .erase, .crop: return TapGestureMappedEmpty()
        }
    }

    // MARK: - Raw Touches

    public func rawTouchMapper() -> CanvasRawTouchMappable {
        switch operation {
        case .pen: return RawTouchMappedPaintingLine(paintLayer: paintLayer, coordinateDelegate: self)
        case .erase: return RawTouchMappedEraser(paintLayer: paintLayer, coordinateDelegate: self)
        case .crop, .select: return RawTouchMappedEmpty()
        }
    }

    // MARK: - Layer Delegate

    private var canvasLayerWidthDiffRatio: CGFloat = 1.0
    private var canvasLayerHeightDiffRatio: CGFloat = 1.0
    public override func layoutSublayers(of layer: CALayer) {

        switch layer.name {
        case PHOTO_PLAY_ROOT_LAYER:
            workspace.frame = layer.bounds

        case PHOTO_PLAY_WORKSPACE_LAYER:
            defer {
                needsLayoutCroppingGuide = nil
            }

            let currentCanvasLayerFrame = canvas.frame

            let nextCanvasLayerFrame: CGRect
            switch operation {
            case .select, .pen, .erase:
                nextCanvasLayerFrame = fitFrame(target: canvasSize, to: workspace.bounds.size)
            case .crop:
                let frame = fitFrame(target: canvasSize, to: workspace.bounds.size)
                nextCanvasLayerFrame = frame.insetBy(dx: frame.width * 0.05, dy: frame.height * 0.05)
            }

            let shouldSetAdjustingTransform: Bool =
                currentCanvasLayerFrame.size != nextCanvasLayerFrame.size &&
                currentCanvasLayerFrame.size.width != 0 &&
                currentCanvasLayerFrame.size.height != 0 &&
                needsAdjustingTransform == nil
            if shouldSetAdjustingTransform {
                needsAdjustingTransform = .layoutWorkspace(adjustTransform: { currentTransform in
                    var newTransform = currentTransform
                    newTransform.m41 *= nextCanvasLayerFrame.width / currentCanvasLayerFrame.width
                    newTransform.m42 *= nextCanvasLayerFrame.height / currentCanvasLayerFrame.height
                    return newTransform
                })
            }

            canvas.frame = nextCanvasLayerFrame
            selectionFrameLayer.frame = nextCanvasLayerFrame
            backgroundLayer.frame = layer.bounds
            outBoundsMask.frame = layer.frame
            outBoundsMask.canvasFrame = nextCanvasLayerFrame
            croppingGuideLayer.frame = switch needsLayoutCroppingGuide {
            case let .crop(toFrame):
                toFrame
            case .none:
                nextCanvasLayerFrame.insetBy(dx: -croppingGuideFrameOffset, dy: -croppingGuideFrameOffset)
            }

        case PHOTO_PLAY_CANVAS_LAYER:
            defer {
                self.needsAdjustingTransform = nil
                canvasLayerWidthDiffRatio = 1.0
                canvasLayerHeightDiffRatio = 1.0
            }

            switch needsAdjustingTransform {
            case let .crop(adjustTransform):
                self.transform = adjustTransform(canvas.frame, self.transform)
            case let .layoutWorkspace(adjustTransform):
                self.transform = adjustTransform(self.transform)
            case .none: break
            }

            baseImageFrame = fillFrame(
                target: CGSize(width: image.width, height: image.height),
                to: canvas.frame.size
            )

            // Relayout image layer
            imageLayer.setFrameIgnoreTransform(baseImageFrame)
            imageLayer.transform = transform

            // Relayout paint layer
            paintLayer.setFrameIgnoreTransform(baseImageFrame)
            paintLayer.transform = transform

            // Relayout overlay layer
            overlayContainerLayer.setFrameIgnoreTransform(baseImageFrame)
            overlayContainerLayer.transform = transform
            for textLayer in overlayContainerLayer.sublayers ?? [] {
                (textLayer as? ParentRelativeLayer)?.relativeLayout(parentBounds: overlayContainerLayer.bounds)
            }

        default: break
        }
    }

    public func draw(_ layer: CALayer, in ctx: CGContext) {
        switch layer.name {
        case PHOTO_PLAY_SELECTION_FRAME_LAYER:
            // Redraw selection frame
            let selectionFramePaths = selectedLayers
                .map { $0.convert($0.bounds, to: selectionFrameLayer) }
                .map { $0.path() }
            selectionFrameLayer.drawSelectionFrame(selectionFramePaths)

        default:
            break
        }
    }

    // MARK: - Types

    enum AdjustingTransformReason {
        case crop(adjustTransform: (CGRect, CATransform3D) -> CATransform3D)
        case layoutWorkspace(adjustTransform: (CATransform3D) -> CATransform3D)
    }

    enum LayoutCroppingGuideReason {
        case crop(toFrame: CGRect)
    }
}
