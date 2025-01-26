import UIKit

extension PhotoPlayViewController {
    @IBAction func didTapCancelBarItem(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func didTapDoneBarItem(_ sender: Any) {
        let renderingContext = canvasManager.render()
        if let image = renderingContext?.cgImage() {
            dismiss(animated: true, completion: { [weak self] in
                self?.completionHandler(image)
            })
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - Helper

    func setUpFloatingButtons() {
        var cancelButtonConfig = UIButton.Configuration.filled()
        cancelButtonConfig.title = nil
        cancelButtonConfig.image = UIImage(systemName: "xmark")?.withConfiguration(UIImage.SymbolConfiguration.init(scale: .medium))
        cancelButtonConfig.imagePadding = 0
        cancelButtonConfig.baseBackgroundColor = .systemGray2
        cancelButtonConfig.cornerStyle = .capsule
        cancelButton.configuration = cancelButtonConfig

        var doneButtonConfig = UIButton.Configuration.filled()
        doneButtonConfig.title = nil
        doneButtonConfig.image = UIImage(systemName: "checkmark")?.withConfiguration(UIImage.SymbolConfiguration.init(scale: .medium))
        doneButtonConfig.imagePadding = 0
        doneButtonConfig.baseBackgroundColor = .systemBlue
        doneButtonConfig.cornerStyle = .capsule
        doneButton.configuration = doneButtonConfig
    }
}
