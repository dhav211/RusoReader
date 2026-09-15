import UIKit

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
