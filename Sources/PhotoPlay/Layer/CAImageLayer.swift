import QuartzCore
import CoreImage

class CAImageLayer: CAEditableLayer {
    private let imageWidth: Int
    private let imageHeight: Int
    private var image: CGImage
    private let rawCIImage: CIImage
    private var imageFilters: [ImageFilter] = []
    private let renderingCIContext: CIContext
    private let renderingQueue: DispatchQueue = DispatchQueue(label: "com.nhiro1109.photo-play.renderingQueue", qos: .userInteractive)
    private let screenScale: CGFloat

    init(
        image: CGImage,
        screenScale: CGFloat = 1.0,
        isSelectable: Bool = true,
        isTransformable: Bool = true
    ) {
        self.imageWidth = image.width
        self.imageHeight = image.height
        self.image = image
        self.rawCIImage = CIImage(cgImage: image)
        self.renderingCIContext = CIContext(options: [
            .workingColorSpace: NSNull()
        ])
        self.screenScale = screenScale
        super.init(isSelectable: isSelectable, isTransformable: isTransformable)

        self.masksToBounds = false
        self.drawsAsynchronously = true
        self.needsDisplayOnBoundsChange = true
    }

    public override init(layer: Any) {
        if let imageLayer = layer as? CAImageLayer {
            self.imageWidth = imageLayer.imageWidth
            self.imageHeight = imageLayer.imageHeight
            self.image = imageLayer.image
            self.rawCIImage = imageLayer.rawCIImage
            self.imageFilters = imageLayer.imageFilters
            self.renderingCIContext = imageLayer.renderingCIContext
            self.screenScale = imageLayer.screenScale
        } else {
            fatalError("Only CAImageLayer can be added.")
        }
        super.init(layer: layer)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSublayers() {
        contentsScale = max(
            CGFloat(imageWidth) / bounds.width,
            CGFloat(imageHeight) / bounds.height,
            1.0
        )
    }

    override func draw(in ctx: CGContext) {
        ctx.translateBy(x: 0, y: bounds.height)
        ctx.scaleBy(x: 1, y: -1)
        ctx.draw(image, in: bounds)
    }

    // MARK: - Filter

    let fullRenderingDelay: TimeInterval = 0.3
    var fullRenderingWorkItem: DispatchWorkItem?
    var resizedRenderingWorkItem: DispatchWorkItem?
    func applyAsync(imageFilters: [ImageFilter]) {
        self.imageFilters = imageFilters

        resizedRenderingWorkItem?.cancel()
        resizedRenderingWorkItem = .init { [weak self] in
            guard let self else { return }
            var date = Date()
            let filteredImage = rawCIImage.applyingFilters(imageFilters).lanczosScaled(scale: bounds.width * screenScale / CGFloat(imageWidth))
            image = renderingCIContext.createCGImage(filteredImage, from: filteredImage.extent) ?? image
            print("Resized Rendering time: \(Date().timeIntervalSince(date))")
            DispatchQueue.main.sync { self.setNeedsDisplay() }
        }
        renderingQueue.async(execute: resizedRenderingWorkItem!)

        fullRenderingWorkItem?.cancel()
        fullRenderingWorkItem = .init { [weak self] in
            guard let self else { return }
            var date = Date()
            image = renderingCIContext.createCGImage(
                rawCIImage.applyingFilters(imageFilters),
                from: rawCIImage.extent
            )!
            print("Full Rendering time: \(Date().timeIntervalSince(date))")
            DispatchQueue.main.sync { self.setNeedsDisplay() }
        }
        renderingQueue.asyncAfter(deadline: .now() + fullRenderingDelay, execute: fullRenderingWorkItem!)
    }

    func apply(imageFilters: [ImageFilter]) {
        self.imageFilters = imageFilters
        image = renderingCIContext.createCGImage(
            rawCIImage.applyingFilters(imageFilters),
            from: rawCIImage.extent
        )!
        setNeedsDisplay()
    }
}
