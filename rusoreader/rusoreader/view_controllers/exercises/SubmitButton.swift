import UIKit

final class SubmitButton: UIButton {
    private var onSubmit: (() -> Void)?
    
    init() {
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        setTitle("Submit", for: .normal)
        setTitleColor(.label, for: .normal)
        layer.cornerRadius = 8
        disable()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setClickHandler(onSubmit: @escaping () -> Void) {
        self.onSubmit = onSubmit
        addTarget(self, action: #selector(didClick), for: .touchUpInside)
    }

    func enable() {
        backgroundColor = .systemGreen
        isEnabled = true
    }

    func disable() {
        backgroundColor = .systemGray
        isEnabled = false
    }
    
    @objc private func didClick() {
        isEnabled = false
        isHidden = true
        onSubmit?()
    }
}