import UIKit

/// A cell for the general Settings UiTableview. A SettingPickerWheelTableViewCell will launch a modal containing a picker wheel where a user can select a single option to change.
final class SettingPickerWheelTableViewCell: UITableViewCell {
    static let reuseIdentifier = "PickerWheelIdentifer"
    let currentSelectedOption = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Sets the properties of the cell the user will see in the settings menu
    /// - Parameters:
    ///   - title: Name of the setting, which is on the left side of the cell
    ///   - currentSelected: The name of the option which is currently selected, which is on the right side of the cell
    func configure(title: String, currentSelected: String) {
        textLabel?.text = title
        currentSelectedOption.text = currentSelected
    }
    
    private func setupLayouts() {
        guard let textLabel = textLabel else { return }
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        currentSelectedOption.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(currentSelectedOption)
        
        NSLayoutConstraint.activate([
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            currentSelectedOption.centerYAnchor.constraint(equalTo: centerYAnchor),
            currentSelectedOption.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
        ])
    }
}
