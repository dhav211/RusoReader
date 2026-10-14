import UIKit

final class ExerciseCompletionBanner: UIViewController {
    private let continueButton = UIButton()
    private var nextExercise: (() -> Void)? = nil
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true // When not hidden the banner will intercept clicks, covering various ui buttons
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Slides open the banner from the bottom of the screen giving the user some visual feedback on the exercise. A closure will be used to set
    /// the continue button for the user to continue forward with the next exercise.
    /// - Parameters:
    ///   - exerciseResult: A grade for the exercise giving a score and pass/fail indication
    ///   - actualAnswer: If the user was wrong, then this will show the correct answer
    ///   - onPressed: A closure which supplies what will happen when user clicks the continue button
    ///
    func open(exerciseResult: ExerciseResult, actualAnswer: NSAttributedString?, onPressed: @escaping () -> Void) {
        view.isHidden = false // now we can unhide it because the animation will begin showing the banner at the bottom

        // set the color of banner based on the grade of the exercise result
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

        // The content stack splits the view horizontally
        // on the left is information on how user did and what htye got wrong
        // on the right is the button to go to the next exercise
        let contentStack = UIStackView()
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .horizontal
        contentStack.alignment = .center
        contentStack.distribution = .equalSpacing
        view.addSubview(contentStack)
        
        let resultInformationStack = UIStackView()
        resultInformationStack.axis = .vertical
        contentStack.addArrangedSubview(resultInformationStack)

        // Gives the user some text based indication on how they did based upon the exercise grade
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

        // If the user got the answer wrong the actualAnswer variable will not be nil
        if let actualAnswer {
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
