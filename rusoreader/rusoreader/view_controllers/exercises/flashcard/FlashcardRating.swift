import UIKit

class FlashcardRating : UIView {
    private var portraitConstraints = [NSLayoutConstraint]()
    private var landscapeConstraints = [NSLayoutConstraint]()
    var onSendResult: (Bool) -> Void
    
    init() {
        self.onSendResult = { _ in }
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct Constraints {
        let centerXAnchor: NSLayoutXAxisAnchor
        let leadingAnchor: NSLayoutXAxisAnchor
        let trailingAnchor: NSLayoutXAxisAnchor
        let bottomAnchor: NSLayoutYAxisAnchor
        let centerYAnchor: NSLayoutYAxisAnchor
    }
    
    func setup(isPortrait: Bool, constraints: Constraints) {
        let configuration = UIImage.SymbolConfiguration(pointSize: 48) // the size of the thumbs up buttons
        translatesAutoresizingMaskIntoConstraints = false
        
        // Thumbs up/down buttons let the user indicate wether they remembered the word correctly or not
        // Their position is based on constraints which are dicated by the phones orientation
        let thumbsUpImage = UIImage(systemName: "hand.thumbsup.circle", withConfiguration: configuration)
        let thumbsUpButton = UIButton()
        thumbsUpButton.translatesAutoresizingMaskIntoConstraints = false
        thumbsUpButton.tintColor = .systemGreen
        thumbsUpButton.setImage(thumbsUpImage, for: .normal)
        thumbsUpButton.addTarget(self, action: #selector(thumbsUpButtonPressed), for: .touchUpInside)
        addSubview(thumbsUpButton)
        
        let thumbsDownImage = UIImage(systemName: "hand.thumbsdown.circle", withConfiguration: configuration)
        let thumbsDownButton = UIButton()
        thumbsDownButton.imageView?.addSymbolEffect(.bounce)
        thumbsDownButton.translatesAutoresizingMaskIntoConstraints = false
        thumbsDownButton.tintColor = .systemRed
        thumbsDownButton.setImage(thumbsDownImage, for: .normal)
        thumbsDownButton.addTarget(self, action: #selector(thumbsDownButtonPressed), for: .touchUpInside)
        addSubview(thumbsDownButton)
        
        // Since the buttons are now initialized we will set the button dependant constraints, these are stored here because if the phone's orientation changes we will activate/deactivate these constraints
        portraitConstraints = [
            thumbsUpButton.centerXAnchor.constraint(equalTo: constraints.centerXAnchor, constant: -30),
            thumbsUpButton.topAnchor.constraint(equalTo: constraints.bottomAnchor, constant: 20),
            thumbsDownButton.centerXAnchor.constraint(equalTo: constraints.centerXAnchor, constant: 30),
            thumbsDownButton.topAnchor.constraint(equalTo: constraints.bottomAnchor, constant: 20)
        ]
        
        landscapeConstraints = [
            thumbsUpButton.trailingAnchor.constraint(equalTo: constraints.leadingAnchor, constant: -30),
            thumbsUpButton.centerYAnchor.constraint(equalTo: constraints.centerYAnchor),
            thumbsDownButton.leadingAnchor.constraint(equalTo: constraints.trailingAnchor, constant: 30),
            thumbsDownButton.centerYAnchor.constraint(equalTo: constraints.centerYAnchor),
        ]
        
        if isPortrait {
            for portraitConstraint in portraitConstraints {
                portraitConstraint.isActive = true
            }
        } else {
            for landscapeConstraint in landscapeConstraints {
                landscapeConstraint.isActive = true
            }
        }
    }
    
    func reorientate(newOrientation: PhoneOrientation) {
        // We flip the thumbs up constraints depending on which orientation the phone now is in
        switch newOrientation{
        case .portrait:
            landscapeConstraints.forEach { constraint in
                constraint.isActive = false
            }
            
            portraitConstraints.forEach { constraint in
                constraint.isActive = true
            }
        case .landscape:
            portraitConstraints.forEach { constraint in
                constraint.isActive = false
            }
            
            landscapeConstraints.forEach { constraint in
                constraint.isActive = true
            }
        case .error:
            return
        }
    }
    
    @objc private func thumbsUpButtonPressed() {
        onSendResult(true)
    }
    
    @objc private func thumbsDownButtonPressed() {
        onSendResult(false)
    }
}
