import UIKit

final class ExerciseCompletionBanner: UIViewController {
    private let continueButton = UIButton()
    private var nextExercise: (() -> Void)? = nil
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func open(exerciseResult: ExerciseResult, actualAnswer: NSAttributedString?, onPressed: @escaping () -> Void) {
        // animate this banner opening from the bottom, should be about .3 seconds
        // if the exercise result is correct the banner will be green, if incorrect it will be red, if almost it should be orange or maybe blue
        // It will compose of an uistackview that is horizontal, the left side will contain the message the right side will have a button that proceed to next exercise
        // in the left side of that stack will have another stack view, this time horizontal. The first element will say correct/incorrect the next will display the correct answer if wrong
        // the the button is pressed the onPressed button will fire and this whole view should dissapear so no need for animation.
        switch exerciseResult.grade {
        case .correct:
            view.backgroundColor = .systemGreen
        case .incorrect:
            view.backgroundColor = .systemRed
        case .almost:
            view.backgroundColor = .systemBlue
        case .error:
            view.backgroundColor = .systemGray
        }
        
        nextExercise = onPressed
        
        let contentStack = UIStackView()
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.distribution = .equalSpacing
        view.addSubview(contentStack)
        
        let resultInformationStack = UIStackView()
        resultInformationStack.axis = .vertical
        contentStack.addArrangedSubview(resultInformationStack)
        
        let gradeText = UILabel()
        gradeText.textColor = .white
        gradeText.text = {
            switch exerciseResult.grade {
            case .correct:
                return "Great Job!"
            case .almost:
                return "So Close!"
            case .incorrect:
                return "Too Bad!"
            case .error:
                return "That's odd, an error"
            }
        }()
        resultInformationStack.addArrangedSubview(gradeText)
        
        if exerciseResult.grade == .almost || exerciseResult.grade == .incorrect {
            let answerLabel = UILabel()
            answerLabel.attributedText = actualAnswer
            answerLabel.textColor = .white
            resultInformationStack.addArrangedSubview(answerLabel)
        }
        
        continueButton.setTitle("Continue", for: .normal)
        continueButton.layer.cornerRadius = 8
        continueButton.addTarget(self, action: #selector(onContinueButtonPressed), for: .touchUpInside)
        contentStack.addArrangedSubview(continueButton)
        
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentStack.topAnchor.constraint(equalTo: view.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.superview?.layoutIfNeeded() // force layout so bounds.height is accurate
        view.transform = CGAffineTransform(translationX: 0, y: view.bounds.height + 40)
        view.isHidden = false

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.view.transform = .identity
        }
    }
    
    @objc private func onContinueButtonPressed() {
        nextExercise?()
    }
}
