import UIKit
class WordEndingExerciseView : UIViewController, Exercise {
    private let viewModel: WordEndingExerciseViewModel
    private let banner: ExerciseBanner
    private let exerciseArea: UIView
    private let inputField: UITextField
    private let submitButton: SubmitButton
    private let completionBanner: ExerciseCompletionBanner
    
    weak var completionDelegate: CompletedExerciseDelegate?
    
    init(viewModel: WordEndingExerciseViewModel) {
        self.viewModel = viewModel
        self.banner = ExerciseBanner(text: "Write the word in the correct ending")
        self.exerciseArea = UIView()
        self.inputField = UITextField()
        self.submitButton = SubmitButton()
        self.completionBanner = ExerciseCompletionBanner()
        super.init(nibName: nil, bundle: nil)

        self.submitButton.setClickHandler {
            self.submit()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        
        exerciseArea.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(banner)
        view.addSubview(exerciseArea)
        addChild(completionBanner)
        view.addSubview(completionBanner.view)
        completionBanner.didMove(toParent: self)
        
        let informationStack = WordEndingInformationView(accentedWord: viewModel.accentedBaseFormText, wordFormText: viewModel.formText)
        exerciseArea.addSubview(informationStack)
        
        let inputStack = UIStackView()
        inputStack.axis = .vertical
        inputStack.alignment = .fill
        inputStack.spacing = 4
        inputStack.translatesAutoresizingMaskIntoConstraints = false
        exerciseArea.addSubview(inputStack)
        
        let inputStackWidth = min((UIScreen.main.bounds.width) * 0.75, 300)
        
        inputField.borderStyle = .roundedRect
        inputField.textColor = .label
        inputField.backgroundColor = .secondarySystemBackground
        inputField.addTarget(self, action: #selector(didEditInputField), for: .editingChanged)
        inputStack.addArrangedSubview(inputField)
        

        view.addSubview(submitButton)
        
        NSLayoutConstraint.activate([
            banner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            banner.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            banner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            exerciseArea.topAnchor.constraint(equalTo: banner.bottomAnchor),
            exerciseArea.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            exerciseArea.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            exerciseArea.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            informationStack.topAnchor.constraint(equalTo: exerciseArea.topAnchor, constant: 8),
            informationStack.centerXAnchor.constraint(equalTo: exerciseArea.centerXAnchor),
            inputStack.widthAnchor.constraint(equalToConstant: inputStackWidth),
            inputStack.centerYAnchor.constraint(equalTo: exerciseArea.centerYAnchor),
            inputStack.centerXAnchor.constraint(equalTo: exerciseArea.centerXAnchor),
            submitButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32),
            submitButton.widthAnchor.constraint(equalToConstant: inputStackWidth),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            completionBanner.view.heightAnchor.constraint(equalToConstant: 200),
            completionBanner.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            completionBanner.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            completionBanner.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func submit() {
        view.endEditing(true)
        guard let answer = inputField.text else { return }
        let result = viewModel.calculateResult(answer)
        completionDelegate?.grade(result: result)
        
        // Take the users inputed answer then compare it to the actual answer while bolding and underlining incorrect letters
        let attributedAnswer = result.grade != .correct ? NSMutableAttributedString(string: viewModel.word.bare) : nil
        // we are grabbing the default text so we can get a bold font point size here in the attributed string
        let defaultFont = UIFont.systemFont(ofSize: UIFont.labelFontSize)

        if let attributedAnswer {
            for affectedIndex in viewModel.createHightlightedDifferenceInAnswer(answer: answer) {
                attributedAnswer.addAttributes(
                    [
                        .underlineStyle: NSUnderlineStyle.single.rawValue,
                        .font: UIFont.boldSystemFont(ofSize: defaultFont.pointSize)
                    ],
                    range: NSRange(location: affectedIndex, length: 1))
            }
        }
        
        
        completionBanner.open(exerciseResult: result, actualAnswer: attributedAnswer) { [weak self] in
            self?.completionDelegate?.next()
        }
    }

    @objc private func didEditInputField() {
        guard let inputText = inputField.text else { return }
        if inputText.count > 0 {
            submitButton.enable()
        } else {
            submitButton.disable()
        }
    }
}
