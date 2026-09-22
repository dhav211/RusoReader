import UIKit

/// Used in the Settings Picker modals, contains a command such as "Choose the default langauge" on the left and a select button on the right.
final class SettingsPickerInformationStack: UIStackView {
    private let informationLabel = UILabel()
    private let selectionButton = UIButton()
    private let information: String
    private let onTapped: () -> Void
    
    init(information: String, onTapped: @escaping () -> Void) {
        self.information = information
        self.onTapped = onTapped
        
        super.init(frame: .zero)
        
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        axis = .horizontal
        distribution = .equalSpacing
        
        informationLabel.text = information
        
        selectionButton.setTitle("Select", for: .normal)
        selectionButton.setTitleColor(.systemBlue, for: .normal)
        selectionButton.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
        
        addArrangedSubview(informationLabel)
        addArrangedSubview(selectionButton)
    }
    
    @objc private func tapButton() {
        onTapped()
    }
}
