import UIKit

final class MultipleChoiceButton: UIButton {
    private var onSelected: (() -> Void)?
    let isCorrect: Bool
    let text: String
    
    init(buttonText: String, isCorrect: Bool) {
        self.isCorrect = isCorrect
        self.text = buttonText
        
        super.init(frame: .zero)

        setTitle(buttonText, for: .normal)
        setTitleColor(.label, for: .normal)
        layer.borderColor = UIColor.label.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 8
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setClickHandler(onSelected: @escaping () -> Void) {
        self.onSelected = onSelected
        addTarget(self, action: #selector(didClick), for: .touchUpInside)
    }

    func deactivate() {
        backgroundColor = .none
        layer.borderColor = UIColor.label.cgColor
    }

    func activate() {
        backgroundColor = .systemBlue
        layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    @objc private func didClick() {
        activate()
        onSelected?()
    }
}