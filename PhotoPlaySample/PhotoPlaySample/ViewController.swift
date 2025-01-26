import UIKit
import PhotosUI
import PhotoPlayUIKit

class ViewController: UIViewController {
    let indicator: UIActivityIndicatorView = .init()
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    private var exportedImage: CGImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        saveButton.isEnabled = false
    }

    @IBAction func didTapSelectButton(_ sender: Any) {
        authorizePhotoLibrary { [weak self] in
            self?.presentPhotoLibrary()
        }
    }
    
    @IBAction func didTapSaveButton(_ sender: Any) {
        if let exportedImage, let imageData = convertToJPEG(cgImage: exportedImage) {
            showSaveAlert(imageData: imageData)
        }
    }

    func presentPhotoLibrary() {
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        configuration.filter = .images
        configuration.preferredAssetRepresentationMode = .current
        configuration.selectionLimit = 1
        let phPickerController = PHPickerViewController(configuration: configuration)
        phPickerController.delegate = self
        present(phPickerController, animated: true)
    }

    func presentPhotoPlay(image: CGImage) {
        let vc = PhotoPlayViewController(image: image, completionHandler: onCompleteImageEditing)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    func onCompleteImageEditing(image: CGImage) {
        self.exportedImage = image
        previewImageView.image = UIImage(cgImage: image)
        saveButton.isEnabled = true
    }
}
