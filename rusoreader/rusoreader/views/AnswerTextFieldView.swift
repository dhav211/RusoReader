import UIKit

final class AnswerTextFieldView: UITextField {
    private var onEdited: (() -> Void)? = nil
    
    var cleanedText: String? {
        return text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "ё", with: "е")
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(width: CGFloat, onEdited: @escaping () -> Void) {
        self.onEdited = onEdited
        
        borderStyle = .roundedRect
        textColor = .label
        backgroundColor = .secondarySystemBackground
        addTarget(self, action: #selector(didEditInputField), for: .editingChanged)
        
        autocorrectionType = .no
        autocapitalizationType = .none
        spellCheckingType = .no
        smartQuotesType = .no
        smartDashesType = .no
        smartInsertDeleteType = .no
        returnKeyType = .done
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: width)
        ])
    }
    
    @objc private func didEditInputField() {
        onEdited?()
    }
}
