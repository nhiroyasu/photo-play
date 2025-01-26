import UIKit

class PhotoPlayFilterMenuCell: UICollectionViewCell {
    @IBOutlet weak var filterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    var tapHandler: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(tapGesture)
    }

    func configure(image: UIImage?, title: String, tapHandler: (() -> Void)?) {
        filterImageView.image = image
        titleLabel.text = title
        self.tapHandler = tapHandler
    }

    @objc func tapAction() {
        tapHandler?()
    }
}
