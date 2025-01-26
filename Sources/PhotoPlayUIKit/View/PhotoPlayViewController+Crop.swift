import UIKit

extension PhotoPlayViewController {
    @IBAction func didTapCropReset() {
        canvasManager.resetCrop()
    }

    @IBAction func didTapRotate() {
        canvasManager.rotateCanvasRightAngle90()
    }

    @IBAction func didTapInvertVertical() {
        canvasManager.invertVertical()
    }

    @IBAction func didTapInvertHorizontal() {
        canvasManager.invertHorizontal()
    }

    // MARK: - Helper

    func setUpCropMenu() {
        cropResizeButton.menu = {
            let menu = UIMenu(children: [
                UIAction(title: "Original", handler: { [weak self] _ in
                    self?.canvasManager.resizeCanvas(size: .original)
                }),
                UIAction(title: "Square", handler: { [weak self] _ in
                    self?.canvasManager.resizeCanvas(size: .square)
                }),
                UIAction(title: "Aspect 16:9", handler: { [weak self] _ in
                    self?.canvasManager.resizeCanvas(size: .aspect16_9)
                }),
                UIAction(title: "Aspect 4:3", handler: { [weak self] _ in
                    self?.canvasManager.resizeCanvas(size: .aspect4_3)
                })
            ])
            return menu
        }()
        cropResizeButton.showsMenuAsPrimaryAction = true
    }
}
