import UIKit

class PhotoPlayTextMenuInputAccessoryView: UIView {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var colorWell: UIColorWell!
    @IBOutlet weak var doneButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadNib() {
        if let view = Bundle(for: type(of: self)).loadNibNamed("PhotoPlayTextMenuInputAccessoryView", owner: self, options: nil)?.first as? UIView {
            view.frame = self.bounds
            self.addSubview(view)
        }
    }

    func configure(textFieldDelegate: UITextFieldDelegate, doneButtonAction: Selector, target: Any) {
        textField.delegate = textFieldDelegate
        doneButton.addTarget(target, action: doneButtonAction, for: .touchUpInside)
    }
}
