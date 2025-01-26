import PhotoPlay
import UIKit

extension PhotoPlayViewController {

    @IBAction func didTapBrightness(_ sender: Any) {
        controlMenuContainerView.isHidden = false

        allUnselectForControlMenu()
        brightnessButton.isSelected = true

        controlSlider.minimumValue = -0.5
        controlSlider.maximumValue = 0.5
        controlSlider.value = brightnessValue
        controlSlider.minimumValueImage = UIImage(systemName: "sun.min.fill")?
            .withConfiguration(
                UIImage.SymbolConfiguration(scale: .small).applying(
                    UIImage.SymbolConfiguration(hierarchicalColor: .label)
                )
            )
        controlSlider.maximumValueImage = UIImage(systemName: "sun.max.fill")?
            .withConfiguration(
                UIImage.SymbolConfiguration(scale: .default).applying(
                    UIImage.SymbolConfiguration(hierarchicalColor: .label)
                )
            )
        onChangeControlSliderValue = { [weak self] newValue in
            guard let self else { return }
            brightnessValue = newValue
            brightnessButton.configuration = .photoPlaySelected(
                image: UIImage(systemName: "sun.min"),
                text: "Brightness \(String(format: "%2.0f", brightnessValue * 100.0))"
            )
            canvasManager.applyImageFilter(imageFilters)
        }
    }

    @IBAction func didTapContrast(_ sender: Any) {
        controlMenuContainerView.isHidden = false

        allUnselectForControlMenu()
        contrastButton.isSelected = true

        controlSlider.minimumValue = 0.5
        controlSlider.maximumValue = 1.5
        controlSlider.value = contrastValue
        controlSlider.minimumValueImage = UIImage(systemName: "circle.lefthalf.filled.righthalf.striped.horizontal.inverse")?
            .withConfiguration(
                UIImage.SymbolConfiguration(scale: .default).applying(
                    UIImage.SymbolConfiguration(hierarchicalColor: .label)
                )
            )
        controlSlider.maximumValueImage = UIImage(systemName: "circle.lefthalf.filled.righthalf.striped.horizontal")?
            .withConfiguration(
                UIImage.SymbolConfiguration(scale: .default).applying(
                    UIImage.SymbolConfiguration(hierarchicalColor: .label)
                )
            )
        onChangeControlSliderValue = { [weak self] newValue in
            guard let self else { return }
            contrastValue = newValue
            contrastButton.configuration = .photoPlaySelected(
                image: UIImage(systemName: "circle.lefthalf.filled"),
                text: "Contrast \(String(format: "%2.0f", (contrastValue - 1.0) * 100))"
            )
            canvasManager.applyImageFilter(imageFilters)
        }
    }

    @IBAction func didTapSaturation(_ sender: Any) {
        controlMenuContainerView.isHidden = false

        allUnselectForControlMenu()
        saturationButton.isSelected = true

        controlSlider.minimumValue = 0
        controlSlider.maximumValue = 2
        controlSlider.value = saturationValue
        controlSlider.minimumValueImage = UIImage(systemName: "lightspectrum.horizontal")?
            .withConfiguration(
                UIImage.SymbolConfiguration(scale: .default).applying(
                    UIImage.SymbolConfiguration(hierarchicalColor: .secondaryLabel)
                )
            )
        controlSlider.maximumValueImage = UIImage(systemName: "lightspectrum.horizontal")?
            .withConfiguration(
                UIImage.SymbolConfiguration(scale: .default).applying(
                    UIImage.SymbolConfiguration(hierarchicalColor: .label)
                )
            )
        onChangeControlSliderValue = { [weak self] newValue in
            guard let self else { return }
            saturationValue = newValue
            saturationButton.configuration = .photoPlaySelected(
                image: UIImage(systemName: "lightspectrum.horizontal"),
                text: "Saturation \(String(format: "%2.0f", (saturationValue - 1.0) * 100.0))"
            )
            canvasManager.applyImageFilter(imageFilters)
        }
    }

    @IBAction func didTapTemperature(_ sender: Any) {
        controlMenuContainerView.isHidden = false

        allUnselectForControlMenu()
        temperatureButton.isSelected = true

        controlSlider.minimumValue = -temperatureMaxValue
        controlSlider.maximumValue = temperatureMaxValue
        controlSlider.value = temperatureDiffValue
        controlSlider.minimumValueImage = UIImage(systemName: "thermometer.variable")?
            .withConfiguration(
                UIImage.SymbolConfiguration(scale: .default).applying(
                    UIImage.SymbolConfiguration(hierarchicalColor: .secondaryLabel)
                )
            )
        controlSlider.maximumValueImage = UIImage(systemName: "thermometer.variable")?
            .withConfiguration(
                UIImage.SymbolConfiguration(scale: .default).applying(
                    UIImage.SymbolConfiguration(hierarchicalColor: .label)
                )
            )
        onChangeControlSliderValue = { [weak self] newValue in
            guard let self else { return }
            temperatureDiffValue = newValue
            temperatureButton.configuration = .photoPlaySelected(
                image: UIImage(systemName: "thermometer.variable"),
                text: "Temperature \(String(format: "%2.0f", (temperatureDiffValue) / temperatureMaxValue * 100))"
            )
            canvasManager.applyImageFilter(imageFilters)
        }
    }

    @IBAction func didTapSharpness(_ sender: Any) {
        controlMenuContainerView.isHidden = false

        allUnselectForControlMenu()
        sharpnessButton.isSelected = true

        controlSlider.minimumValue = 0
        controlSlider.maximumValue = 0.8
        controlSlider.value = sharpnessValue
        controlSlider.minimumValueImage = UIImage(systemName: "righttriangle")?
            .withConfiguration(
                UIImage.SymbolConfiguration(scale: .small).applying(
                    UIImage.SymbolConfiguration(hierarchicalColor: .label)
                )
            )
        controlSlider.maximumValueImage = UIImage(systemName: "righttriangle")?
            .withConfiguration(
                UIImage.SymbolConfiguration(scale: .default).applying(
                    UIImage.SymbolConfiguration(hierarchicalColor: .label)
                )
            )
        onChangeControlSliderValue = { [weak self] newValue in
            guard let self else { return }
            sharpnessValue = newValue
            sharpnessButton.configuration = .photoPlaySelected(
                image: UIImage(systemName: "righttriangle"),
                text: "Sharpness \(String(format: "%2.0f", (sharpnessValue - sharpnessDefaultValue) * 100.0))"
            )
            canvasManager.applyImageFilter(imageFilters)
        }
    }

    @IBAction func didChangeControlSliderValue(_ sender: Any) {
        onChangeControlSliderValue?(controlSlider.value)
    }

    // MARK: - Helper
    
    func setUpControlMenu() {
        controlMenuScrollView.contentInset = .init(top: 0, left: 16, bottom: 0, right: 16)

        controlSlider.isContinuous = true


        brightnessButton.configurationUpdateHandler = { [weak self] button in
            guard let self else { return }
            if button.isSelected {
                button.configuration = .photoPlaySelected(
                    image: UIImage(systemName: "sun.min"),
                    text: "Brightness \(String(format: "%2.0f", brightnessValue * 100.0))"
                )
            } else {
                button.configuration = .photoPlayNormal(
                    image: UIImage(systemName: "sun.min"),
                    text: "Brightness \(String(format: "%2.0f", brightnessValue * 100.0))"
                )
            }
        }
        contrastButton.configurationUpdateHandler = { [weak self] button in
            guard let self else { return }
            if button.isSelected {
                button.configuration = .photoPlaySelected(
                    image: UIImage(systemName: "circle.lefthalf.filled"),
                    text: "Contrast \(String(format: "%2.0f", (contrastValue - 1.0) * 100))"
                )
            } else {
                button.configuration = .photoPlayNormal(
                    image: UIImage(systemName: "circle.lefthalf.filled"),
                    text: "Contrast \(String(format: "%2.0f", (contrastValue - 1.0) * 100))"
                )
            }
        }
        saturationButton.configurationUpdateHandler = { [weak self] button in
            guard let self else { return }
            if button.isSelected {
                button.configuration = .photoPlaySelected(
                    image: UIImage(systemName: "lightspectrum.horizontal"),
                    text: "Saturation \(String(format: "%2.0f", (saturationValue - 1.0) * 100.0))"
                )
            } else {
                button.configuration = .photoPlayNormal(
                    image: UIImage(systemName: "lightspectrum.horizontal"),
                    text: "Saturation \(String(format: "%2.0f", (saturationValue - 1.0) * 100.0))"
                )
            }
        }
        temperatureButton.configurationUpdateHandler = { [weak self] button in
            guard let self else { return }
            if button.isSelected {
                button.configuration = .photoPlaySelected(
                    image: UIImage(systemName: "thermometer.variable"),
                    text: "Temperature \(String(format: "%2.0f", (temperatureDiffValue) / temperatureMaxValue * 100))"
                )
            } else {
                button.configuration = .photoPlayNormal(
                    image: UIImage(systemName: "thermometer.variable"),
                    text: "Temperature \(String(format: "%2.0f", (temperatureDiffValue) / temperatureMaxValue * 100))"
                )
            }
        }
        sharpnessButton.configurationUpdateHandler = { [weak self] button in
            guard let self else { return }
            if button.isSelected {
                button.configuration = .photoPlaySelected(
                    image: UIImage(systemName: "righttriangle"),
                    text: "Sharpness \(String(format: "%2.0f", (sharpnessValue - sharpnessDefaultValue) * 100.0))"
                )
            } else {
                button.configuration = .photoPlayNormal(
                    image: UIImage(systemName: "righttriangle"),
                    text: "Sharpness \(String(format: "%2.0f", (sharpnessValue - sharpnessDefaultValue) * 100.0))"
                )
            }
        }
    }

    func allUnselectForControlMenu() {
        brightnessButton.isSelected = false
        contrastButton.isSelected = false
        saturationButton.isSelected = false
        temperatureButton.isSelected = false
        sharpnessButton.isSelected = false
    }
}
