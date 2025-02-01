import UIKit
import PhotosUI

extension PhotoPlayViewController {

    @IBAction func didTapCrop(_ sender: Any) {
        allUnselectForMenu()
        cropButton.isSelected = true

        cropMenuContainerView.isHidden = false

        canvasManager.setOperation(.crop)
    }

    @IBAction func didTapControl(_ sender: Any) {
        allUnselectForMenu()
        controlButton.isSelected = true

        controlMenuContainerView.isHidden = false

        allUnselectForControlMenu()
        brightnessButton.isSelected = true

        didTapBrightness(self)

        canvasManager.setOperation(.select)
    }

    @IBAction func didTapFilter(_ sender: Any) {
        allUnselectForMenu()
        filterButton.isSelected = true

        filterMenuContainerView.isHidden = false

        canvasManager.setOperation(.select)
    }

    @IBAction func didTapPaint(_ sender: Any) {
        allUnselectForMenu()
        paintButton.isSelected = true

        paintMenuContainerView.isHidden = false

        didTapPenSize(self)
    }

    func didTapText() {
        allUnselectForMenu()
        moreButton.isSelected = true

        textMenuContainerView.isHidden = false

        canvasManager.setOperation(.select)
        textField.becomeFirstResponder()
    }

    func didTapImage() {
        allUnselectForMenu()
        moreButton.isSelected = true

        // TODO: Authorization
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        configuration.filter = .images
        configuration.preferredAssetRepresentationMode = .current
        configuration.selectionLimit = 1
        let phPickerController = PHPickerViewController(configuration: configuration)
        phPickerController.delegate = self
        present(phPickerController, animated: true)

        canvasManager.setOperation(.select)
    }

    func selectedImage(image: CGImage) {
        canvasManager.addImage(image: image)
        moreButton.isSelected = false
    }

    // MARK: - Helper

    func setUpMainMenu() {
        cropButton.configurationUpdateHandler = { [weak self] button in
            guard let self else { return }
            button.configuration = .mainMenu(
                image: UIImage(systemName: "crop.rotate"),
                text: "Crop",
                isSelected: button.isSelected
            )
        }

        controlButton.configurationUpdateHandler = { [weak self] button in
            guard let self else { return }
            button.configuration = .mainMenu(
                image: UIImage(systemName: "slider.horizontal.3"),
                text: "Control",
                isSelected: button.isSelected
            )
        }

        filterButton.configurationUpdateHandler = { [weak self] button in
            guard let self else { return }
            button.configuration = .mainMenu(
                image: UIImage(systemName: "camera.filters"),
                text: "Filter",
                isSelected: button.isSelected
            )
        }

        paintButton.configurationUpdateHandler = { [weak self] button in
            guard let self else { return }
            button.configuration = .mainMenu(
                image: UIImage(systemName: "paintbrush.pointed"),
                text: "Paint",
                isSelected: button.isSelected
            )
        }

        moreButton.configurationUpdateHandler = { [weak self] button in
            guard let self else { return }
            button.configuration = .mainMenu(
                image: UIImage(systemName: "ellipsis"),
                text: "More",
                isSelected: button.isSelected
            )
        }

        moreButton.menu = {
            let menu = UIMenu(children: [
                UIAction(title: "Text", image: UIImage(systemName: "textformat"), handler: { [weak self] _ in
                    self?.didTapText()
                }),
                UIAction(title: "Image", image: UIImage(systemName: "photo.on.rectangle.angled"), handler: { [weak self] _ in
                    self?.didTapImage()
                }),
            ])
            return menu
        }()
        moreButton.showsMenuAsPrimaryAction = true
    }

    func allUnselectForMenu() {
        cropButton.isSelected = false
        controlButton.isSelected = false
        filterButton.isSelected = false
        moreButton.isSelected = false
        paintButton.isSelected = false

        cropMenuContainerView.isHidden = true
        controlMenuContainerView.isHidden = true
        filterMenuContainerView.isHidden = true
        paintMenuContainerView.isHidden = true
        textMenuContainerView.isHidden = true
        selectionMenuContainerView.isHidden = true
    }
}
