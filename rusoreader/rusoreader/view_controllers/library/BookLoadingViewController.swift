import UIKit

/// A basic view letting the user know a book is being parsed and is taking a little longer than usual, this will also let the user cancel the action if they suspect something has gone awry.
final class BookLoadingViewController: UIViewController {
    private let loadingLabel = UILabel()
    private let loadingIndicator = UIActivityIndicatorView()
    private let cancelButton = UIButton()
    
    var onCancelled: (() -> Void)?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        onCancelled?()
    }
    
    private func setup() {
        view.backgroundColor = .systemBackground
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        let loadingStack = UIStackView()
        loadingStack.axis = .horizontal
        loadingStack.spacing = 4
        stack.addArrangedSubview(loadingStack)
        
        loadingIndicator.startAnimating()
        loadingStack.addArrangedSubview(loadingIndicator)
        
        loadingLabel.text = "Your book is loading"
        loadingStack.addArrangedSubview(loadingLabel)
        
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelButton.setTitleColor(.label, for: .normal)
        stack.addArrangedSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    @objc private func cancelTapped() {
        onCancelled?()
    }
}
