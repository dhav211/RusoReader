import UIKit

class LabeledTextField : UIStackView {
    private let textField: UITextField
    
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
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getTextFieldValue() -> String {
        return textField.text ?? ""
    }
}
