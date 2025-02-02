import UIKit
import PhotoPlay
import Combine

public class PhotoPlayViewController: UIViewController {
    var indicator: UIActivityIndicatorView = .init()

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!

    @IBOutlet weak var canvasContainerView: UIView!

    @IBOutlet weak var menuContainerView: UIView!
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var controlButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var paintButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var menuContainerViewBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var cropMenuContainerView: UIView!
    @IBOutlet weak var cropResizeButton: UIButton!

    @IBOutlet weak var controlMenuContainerView: UIView!
    @IBOutlet weak var controlMenuScrollView: UIScrollView!
    @IBOutlet weak var brightnessButton: UIButton!
    @IBOutlet weak var contrastButton: UIButton!
    @IBOutlet weak var saturationButton: UIButton!
    @IBOutlet weak var temperatureButton: UIButton!
    @IBOutlet weak var sharpnessButton: UIButton!
    @IBOutlet weak var controlSliderContainerView: UIView!
    @IBOutlet weak var controlSlider: UISlider!
    var onChangeControlSliderValue: ((Float) -> Void)?
    var brightnessValue: Float = 0
    var contrastValue: Float = 1
    var saturationValue: Float = 1
    var temperatureDiffValue: Float = 0
    let temperatureMaxValue: Float = 4000
    var sharpnessValue: Float = 0.4
    let sharpnessDefaultValue: Float = 0.4

    @IBOutlet weak var filterMenuContainerView: UIView!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    var filterDataSource: UICollectionViewDiffableDataSource<FilterMenuSection, FilterMenuItem>!
    var selectedFilterType: FilterType?

    @IBOutlet weak var paintMenuContainerView: UIView!
    @IBOutlet weak var paintMenuSliderContainerView: UIView!
    @IBOutlet weak var paintMenuSlider: UISlider!
    @IBOutlet weak var paintMenuScrollView: UIScrollView!
    @IBOutlet weak var penButton: UIButton!
    @IBOutlet weak var penColorWell: UIColorWell!
    @IBOutlet weak var eraserButton: UIButton!
    @IBOutlet weak var undoPaintButton: UIButton!
    @IBOutlet weak var redoPaintButton: UIButton!
    var onChangePaintSliderValue: ((Float) -> Void)?
    var penSizeValue: Float = 50
    var eraserSize: Float = 200

    @IBOutlet weak var textMenuContainerView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textEnterButton: UIButton!
    @IBOutlet weak var textColorWell: UIColorWell!
    private var textMenuInputAccessoryView: PhotoPlayTextMenuInputAccessoryView!

    @IBOutlet weak var selectionMenuContainerView: UIView!
    @IBOutlet weak var selectionLayerDeleteButton: UIButton!

    var cancellable: Set<AnyCancellable> = []

    let canvasViewDispatchQueue = DispatchQueue(
        label: "com.nhiro1109.PhotoPlay.canvasView"
    )

    var canvasView: PhotoPlayCanvasView!
    var canvasManager: CAImageCanvasManager!

    let image: CGImage
    let completionHandler: (CGImage) -> Void

    public init(image: CGImage, completionHandler: @escaping (CGImage) -> Void) {
        self.image = image
        self.completionHandler = completionHandler
        super.init(nibName: "PhotoPlayViewController", bundle: Bundle.module)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("deinit PhotoPlayViewController")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        // setup

        setUpCanvas(for: image)

        setUpFloatingButtons()

        menuContainerView.isHidden = false
        setUpMainMenu()

        cropMenuContainerView.isHidden = true
        setUpCropMenu()

        controlMenuContainerView.isHidden = true
        setUpControlMenu()

        filterMenuContainerView.isHidden = true
        setUpFilterMenu()

        paintMenuContainerView.isHidden = true
        setUpPaintMenu()

        textMenuContainerView.isHidden = true
        setUpTextMenu()

        selectionMenuContainerView.isHidden = true
        setUpSelectionMenu()



        // default setting
        canvasManager.setPen(
            .gPen(
                color: penColorWell.selectedColor?.cgColor ?? UIColor.white.cgColor,
                size: CGFloat(penSizeValue)
            )
        )
        canvasManager.setEraserSize(CGFloat(eraserSize))
        canvasManager.setOperation(.select)
    }

    func setUpCanvas(for image: CGImage) {
        let contentBounds = CGRect(
            x: 0,
            y: 0,
            width: view.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right,
            height: view.bounds.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom
        )
        let configuration = CanvasConfiguration(contentsScale: UIScreen.main.scale)
        canvasManager = .init(with: image, configuration: configuration)
        canvasView = .init(frame: contentBounds, canvasManager: canvasManager)
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.backgroundColor = .white

        canvasContainerView.insertSubview(canvasView, at: 0)
        NSLayoutConstraint.activate([
            canvasView.leadingAnchor.constraint(equalTo: canvasContainerView.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: canvasContainerView.trailingAnchor),
            canvasView.topAnchor.constraint(equalTo: canvasContainerView.topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: canvasContainerView.bottomAnchor)
        ])

        canvasManager.selectionStatePublisher()
            .sink { [weak self] isSelecting in
                if isSelecting {
                    self?.allUnselectForMenu()
                    self?.selectionMenuContainerView.isHidden = false
                } else {
                    self?.selectionMenuContainerView.isHidden = true
                }
            }
            .store(in: &cancellable)
    }
}
