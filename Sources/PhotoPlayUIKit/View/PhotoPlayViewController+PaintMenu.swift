import UIKit

extension PhotoPlayViewController {
    @IBAction func didTapPenSize(_ sender: Any) {
        allDeselectForPaintMenu()
        penButton.isSelected = true

        if penButton.isSelected {
            paintMenuSliderContainerView.isHidden = false
            penColorWell.isHidden = false
            paintMenuSlider.minimumValue = 10
            paintMenuSlider.maximumValue = 500
            paintMenuSlider.value = penSizeValue
            onChangePaintSliderValue = { [weak self] newValue in
                guard let self else { return }
                penSizeValue = newValue
                penButton.configuration?.attributedTitle = penAttrStr(newValue)
                canvasManager.setPen(
                    .gPen(
                        color: self.penColorWell.selectedColor?.cgColor ?? UIColor.white.cgColor,
                        size: CGFloat(penSizeValue)
                    )
                )
            }

            canvasManager.setOperation(.pen)
        }
    }

    @IBAction func didChangePaintSliderValue(_ sender: UISlider) {
        onChangePaintSliderValue?(sender.value)
    }

    @IBAction func didTapEraser(_ sender: Any) {
        allDeselectForPaintMenu()
        eraserButton.isSelected = true

        if eraserButton.isSelected {
            paintMenuSliderContainerView.isHidden = false
            penColorWell.isHidden = true
            paintMenuSlider.minimumValue = 10
            paintMenuSlider.maximumValue = 500
            paintMenuSlider.value = eraserSize
            onChangePaintSliderValue = { [weak self] newValue in
                guard let self else { return }
                eraserSize = newValue
                eraserButton.configuration?.attributedTitle = eraserAttrStr(newValue)
                canvasManager.setEraserSize(CGFloat(newValue))
            }

            canvasManager.setOperation(.erase)
        }
    }

    // MARK: - Helper

    func setUpPaintMenu() {
        paintMenuScrollView.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)

        // set up pen color well
        penColorWell.selectedColor = .white
        penColorWell.publisher(for: \.selectedColor, options: [.initial, .new]).sink { [weak self] color in
            guard let self else { return }
            canvasManager.setPen(
                .gPen(
                    color: color?.cgColor ?? UIColor.white.cgColor,
                    size: CGFloat(penSizeValue)
                )
            )
        }.store(in: &cancellable)

        penButton.configurationUpdateHandler = { [weak self] button in
            guard let self else { return }
            if button.isSelected {
                button.configuration = .photoPlaySelected(
                    image: UIImage(systemName: "scribble.variable"),
                    text: "Pen \(String(format: "%2.0f", penSizeValue))pt"
                )
            } else {
                button.configuration = .photoPlayNormal(
                    image: UIImage(systemName: "scribble.variable"),
                    text: "Pen \(String(format: "%2.0f", penSizeValue))pt"
                )
            }
        }

        eraserButton.configurationUpdateHandler = { [weak self] button in
            guard let self else { return }
            if button.isSelected {
                button.configuration = .photoPlaySelected(
                    image: UIImage(systemName: "eraser"),
                    text: "Eraser \(String(format: "%2.0f", eraserSize))pt"
                )
            } else {
                button.configuration = .photoPlayNormal(
                    image: UIImage(systemName: "eraser"),
                    text: "Eraser \(String(format: "%2.0f", eraserSize))pt"
                )
            }
        }
    }

    private func penAttrStr(_ value: Float) -> AttributedString {
        return AttributedString(
            "Pen \(String(format: "%2.0f", value))pt",
            attributes: .init([
                .font: UIFont.systemFont(ofSize: 12)
            ])
        )
    }

    private func eraserAttrStr(_ value: Float) -> AttributedString {
        return AttributedString(
            "Eraser \(String(format: "%2.0f", value))pt",
            attributes: .init([
                .font: UIFont.systemFont(ofSize: 12)
            ])
        )
    }

    private func allDeselectForPaintMenu() {
        penButton.isSelected = false
        eraserButton.isSelected = false
    }
}
