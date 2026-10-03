import UIKit

class LabeledTextField : UIStackView {
    private let textField: UITextField
    
    var onUpdated: (() -> Void)?
    
    init(labelText: String, defaultFieldText: String) {
        let label = UILabel()
        label.text = labelText
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        
        textField = UITextField()
        textField.text = defaultFieldText
        textField.borderStyle = .roundedRect

        super.init(frame: .zero)
        
        addArrangedSubview(label)
        addArrangedSubview(textField)
        axis = .vertical

        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getTextFieldValue() -> String {
        return textField.text ?? ""
    }
    
    @objc private func textChanged() {
        onUpdated?()
    }
}
