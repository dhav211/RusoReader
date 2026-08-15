import UIKit

protocol ReaderViewSettingsDelegate: AnyObject {
    func updateTextSize(to newSize: Float)
}

final class ReaderViewSettingsController: UIViewController {
    let textSizeAdjustmentSlider: UISlider
    var currentTextSize: Float

    weak var delegate: ReaderViewSettingsDelegate?
    
    init(currentTextSize: Float) {
        textSizeAdjustmentSlider = UISlider()
        self.currentTextSize = currentTextSize
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        // This stackview will set the 3 rows of settings, also the only one that is bound by constraints
        let settingsRowsStack = UIStackView()
        settingsRowsStack.axis = .vertical
        settingsRowsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(settingsRowsStack)

        // A simple stack which will hold an icon representing the text size and slider that will change the font size
        let textSizeAdjustmentStack = UIStackView()
        textSizeAdjustmentStack.axis = .horizontal
        textSizeAdjustmentStack.spacing = 8
        settingsRowsStack.addArrangedSubview(textSizeAdjustmentStack)

        textSizeAdjustmentStack.addArrangedSubview(UIImageView(image: UIImage(systemName: "textformat.size")))
        textSizeAdjustmentStack.addArrangedSubview(textSizeAdjustmentSlider)
        textSizeAdjustmentSlider.addTarget(self, action: #selector(onSliderAdjusted), for: .valueChanged)
        textSizeAdjustmentSlider.minimumValue = 12
        textSizeAdjustmentSlider.maximumValue = 24
        textSizeAdjustmentSlider.value = currentTextSize

        NSLayoutConstraint.activate([
            settingsRowsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            settingsRowsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            settingsRowsStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
        ])
    }

    @objc private func onSliderAdjusted(_ sender: UISlider) {
        // ensures the slider will only move in increments of 2
        let step: Float =  2
        let roundedValue = round(sender.value / step) * step
        // snaps the thumb to the stepped position
        sender.value = roundedValue
        currentTextSize = sender.value
        delegate?.updateTextSize(to: currentTextSize)
    }
}