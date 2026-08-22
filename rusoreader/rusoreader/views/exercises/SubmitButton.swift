import UIKit

final class SubmitButton: UIButton {
    private var onSubmit: (() -> Void)?
    
    init() {
        super.init(frame: .zero)

        setTitle("Submit", for: .normal)
        setTitleColor(.label, for: .normal)
        backgroundColor = .systemGreen
        layer.cornerRadius = 8
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setClickHandler(onSubmit: @escaping () -> Void) {
        self.onSubmit = onSubmit
        addTarget(self, action: #selector(didClick), for: .touchUpInside)
    }
    
    @objc private func didClick() {
        onSubmit?()
    }
}