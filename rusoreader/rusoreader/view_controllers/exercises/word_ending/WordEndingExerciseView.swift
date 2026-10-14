import UIKit
class WordEndingExerciseView : ExerciseViewController, UITextFieldDelegate {
    private let viewModel: WordEndingExerciseViewModel
    private let inputField: UITextField
    
    init(viewModel: WordEndingExerciseViewModel) {
        self.viewModel = viewModel
        self.inputField = UITextField()
        
        super.init(
            banner: ExerciseBanner(text: "Write the word in the correct ending"),
            submitButton: SubmitButton(),
            completionBanner: ExerciseCompletionBanner()
        )
        
        if let submitButton = self.submitButton {
            submitButton.setClickHandler { [weak self] in
                self?.submit()
            }
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func setup() {
        super.setup()
        
        let informationStack = WordEndingInformationView(accentedWord: viewModel.accentedBaseFormText, wordFormText: viewModel.formText)
        exerciseArea.addSubview(informationStack)
        
        let inputStack = createInputStack()
        inputStack.addArrangedSubview(inputField)
        
        setupInputField()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        view.backgroundColor = .systemBackground
        
        NSLayoutConstraint.activate([
            informationStack.topAnchor.constraint(equalTo: exerciseArea.topAnchor, constant: 8),
            informationStack.centerXAnchor.constraint(equalTo: exerciseArea.centerXAnchor),
        ])
    }
    
    private func submit() {
        view.endEditing(true)
        if let submitButton {
            submitButton.isHidden = true
        }
        guard let answer = inputField.text else { return }
        let result = viewModel.calculateResult(answer)
        completionDelegate?.grade(result: result)
        
        // Take the users inputed answer then compare it to the actual answer while bolding and underlining incorrect letters
        let attributedAnswer = result.grade != .correct
            ? NSMutableAttributedString(
                string: viewModel.findClosestWordFormVariation(
                    to: viewModel.cleanAnswerInput(answer)
                )
            )
            : nil
        // we are grabbing the default text so we can get a bold font point size here in the attributed string
        let defaultFont = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        let highlightedDifference = viewModel.createHightlightedDifferenceInAnswer(answer: answer)
        
        if let attributedAnswer {
            for affectedIndex in highlightedDifference {
                attributedAnswer.addAttributes(
                    [
                        .underlineStyle: NSUnderlineStyle.single.rawValue,
                        .font: UIFont.boldSystemFont(ofSize: defaultFont.pointSize)
                    ],
                    range: NSRange(location: affectedIndex, length: 1))
            }
        }
        
        guard let completionBanner else { return }
        
        completionBanner.open(exerciseResult: result, actualAnswer: attributedAnswer) { [weak self] in
            self?.completionDelegate?.next()
        }
    }
    
    // Handles when the user hits the return key on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        submit()
        textField.resignFirstResponder()  // dismiss keyboard
        return true
    }

    // When the user edits the answer field, this will enable and disable the submit button depending on if there is any text in the answer field
    @objc private func didEditInputField() {
        guard let submitButton else { return }
        guard let inputText = inputField.text else { return }
        
        if inputText.count > 0 {
            submitButton.enable()
        } else {
            submitButton.disable()
        }
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    private func createInputStack() -> UIStackView {
        let inputStack = UIStackView()
        inputStack.axis = .vertical
        inputStack.alignment = .fill
        inputStack.spacing = 4
        inputStack.translatesAutoresizingMaskIntoConstraints = false
        exerciseArea.addSubview(inputStack)
        
        let inputStackWidth = min((UIScreen.main.bounds.width) * 0.75, 300)
        
        NSLayoutConstraint.activate([
            inputStack.widthAnchor.constraint(equalToConstant: inputStackWidth),
            inputStack.centerYAnchor.constraint(equalTo: exerciseArea.centerYAnchor),
            inputStack.centerXAnchor.constraint(equalTo: exerciseArea.centerXAnchor),
        ])
        
        return inputStack
    }
    
    private func setupInputField() {
        inputField.borderStyle = .roundedRect
        inputField.textColor = .label
        inputField.backgroundColor = .secondarySystemBackground
        inputField.addTarget(self, action: #selector(didEditInputField), for: .editingChanged)
        
        inputField.delegate = self
        inputField.returnKeyType = .done
    }
}
