import UIKit

extension PhotoPlayViewController {
    @IBAction func didTapDeleteSelectionLayer() {
        canvasManager.removeSelectingLayer()
    }

    // MARK: - Helper

    func setUpSelectionMenu() {
        selectionLayerDeleteButton.configurationUpdateHandler = { [weak self] button in
            if button.isSelected {
                button.configuration = .destructiveSelected(
                    image: UIImage(systemName: "trash")?.withConfiguration(UIImage.SymbolConfiguration(scale: .medium)),
                    text: "Delete"
                )
            } else {
                button.configuration = .destructiveIdle(
                    image: UIImage(systemName: "trash")?.withConfiguration(UIImage.SymbolConfiguration(scale: .medium)),
                    text: "Delete"
                )
            }
        }
    }
}
