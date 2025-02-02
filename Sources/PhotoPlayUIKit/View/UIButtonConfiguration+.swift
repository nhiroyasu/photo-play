import UIKit

extension UIButton.Configuration {
    static func photoPlayNormal(image: UIImage?, text: String) -> Self {
        var config = Self.filled()
        config.attributedTitle = AttributedString(
            text,
            attributes: AttributeContainer([
                .font: UIFont.systemFont(ofSize: 12)
            ])
        )
        config.image = image
        config.imagePadding = 4
        config.imagePlacement = .top
        config.baseForegroundColor = .label
        config.baseBackgroundColor = .systemBackground
        config.cornerStyle = .medium
        return config
    }

    static func photoPlayDisabled(image: UIImage?, text: String) -> Self {
        var config = Self.filled()
        config.attributedTitle = AttributedString(
            text,
            attributes: AttributeContainer([
                .font: UIFont.systemFont(ofSize: 12)
            ])
        )
        config.image = image
        config.imagePadding = 4
        config.imagePlacement = .top
        config.baseForegroundColor = .tertiaryLabel
        config.baseBackgroundColor = .systemBackground
        config.cornerStyle = .medium
        return config
    }

    static func photoPlaySelected(image: UIImage?, text: String) -> Self {
        var config = Self.filled()
        config.attributedTitle = AttributedString(
            text,
            attributes: AttributeContainer([
                .font: UIFont.systemFont(ofSize: 12)
            ])
        )
        config.image = image
        config.imagePadding = 4
        config.imagePlacement = .top
        config.baseForegroundColor = .systemBlue
        config.baseBackgroundColor = .secondarySystemBackground
        config.cornerStyle = .medium
        return config
    }

    static func destructiveIdle(image: UIImage?, text: String) -> Self {
        var config = Self.filled()
        config.attributedTitle = AttributedString(
            text,
            attributes: AttributeContainer([
                .font: UIFont.systemFont(ofSize: 12)
            ])
        )
        config.image = image
        config.imagePadding = 4
        config.imagePlacement = .top
        config.baseForegroundColor = .systemRed
        config.baseBackgroundColor = .systemBackground
        config.cornerStyle = .medium
        return config
    }

    static func destructiveSelected(image: UIImage?, text: String) -> Self {
        var config = Self.filled()
        config.attributedTitle = AttributedString(
            text,
            attributes: AttributeContainer([
                .font: UIFont.systemFont(ofSize: 12)
            ])
        )
        config.image = image
        config.imagePadding = 4
        config.imagePlacement = .top
        config.baseForegroundColor = .systemRed
        config.baseBackgroundColor = .secondarySystemBackground
        config.cornerStyle = .medium
        return config
    }

    static func mainMenu(image: UIImage?, text: String, isSelected: Bool) -> Self {
        var config = Self.plain()
        config.attributedTitle = AttributedString(
            text,
            attributes: AttributeContainer([
                .font: UIFont.systemFont(ofSize: 12)
            ])
        )
        config.image = image?.withConfiguration(UIImage.SymbolConfiguration(scale: .medium))
        config.imagePadding = 4
        config.imagePlacement = .top
        config.baseForegroundColor = isSelected ? .systemBlue : .label
        config.baseBackgroundColor = .systemBackground
        config.cornerStyle = .medium
        return config
    }
}
