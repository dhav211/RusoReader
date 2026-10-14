import UIKit

final class ExerciseBanner : UIView {
    init(text: String) {
        super.init(frame: .zero)
        
        setup(text: text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(text: String) {
        translatesAutoresizingMaskIntoConstraints = false
        
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.text = text
        addSubview(textLabel)
        
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .opaqueSeparator
        addSubview(separator)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: textLabel.intrinsicContentSize.height + 16),
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1.5),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
        
    }
    
}
