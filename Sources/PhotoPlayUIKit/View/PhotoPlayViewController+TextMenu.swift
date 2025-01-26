import UIKit

extension PhotoPlayViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty,
           let color = textColorWell.selectedColor {
            addTextLayerWithResign(
                text: text,
                fontName: "Helvetica",
                fontSize: 48,
                color: color
            )
        } else {
            resignTextField()
        }
        return false
    }
}

extension PhotoPlayViewController {
    @IBAction func didTapTextDoneButton(_ sender: UIButton) {
        if let text = textField.text,
              !text.isEmpty,
           let color = textColorWell.selectedColor {
            addTextLayerWithResign(
                text: text,
                fontName: "Helvetica",
                fontSize: 48,
                color: color
            )
        } else {
            resignTextField()
        }
    }

    // MARK: - Helper

    func setUpTextMenu() {
        textField.returnKeyType = .done
        textField.delegate = self
        
        textColorWell.selectedColor = .white
        
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] notification in
                guard let self = self else { return }
                guard let userInfo = notification.userInfo else { return }
                guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                let screen = if let screen = notification.object as? UIScreen {
                    screen
                } else {
                    UIScreen.main
                }
                let fromCoordinatorSpace = screen.coordinateSpace
                let toCoordinatorSpace: UICoordinateSpace = view
                let convertedKeyboardFrame = fromCoordinatorSpace.convert(keyboardFrame, to: toCoordinatorSpace)
                let interSection = view.bounds.intersection(convertedKeyboardFrame)
                let bottomOffset = if !interSection.isEmpty {
                    view.bounds.maxY - interSection.minY - view.safeAreaInsets.bottom
                } else {
                    view.safeAreaInsets.bottom
                }
                menuContainerViewBottomConstraint.constant = bottomOffset
            }
            .store(in: &cancellable)

        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                guard let self = self else { return }
                menuContainerViewBottomConstraint.constant = 0
            }
            .store(in: &cancellable)
    }

    private func addTextLayerWithResign(
        text: String,
        fontName: String,
        fontSize: CGFloat,
        color: UIColor
    ) {
        canvasManager.addText(
            text: text,
            fontName: fontName,
            fontSize: fontSize,
            color: color.cgColor
        )

        resignTextField()
    }

    private func resignTextField() {
        textField.text = ""
        textField.resignFirstResponder()
        textMenuContainerView.isHidden = true
        moreButton.isSelected = false
    }
}
