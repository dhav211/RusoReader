import UIKit
class WordEndingExerciseView : ExerciseViewController, UITextFieldDelegate {
    private let viewModel: WordEndingExerciseViewModel
    private let answerField: AnswerTextFieldView
    
    init(viewModel: WordEndingExerciseViewModel) {
        self.viewModel = viewModel
        self.answerField = AnswerTextFieldView()
        
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
        exerciseArea.addSubview(answerField)
        
        answerField.translatesAutoresizingMaskIntoConstraints = false
        answerField.setup(
            width: min((UIScreen.main.bounds.width) * 0.75, 300),
            onEdited: { [weak self] in self?.didEditInputField() }
        )
        answerField.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        view.backgroundColor = .systemBackground
        
        
        NSLayoutConstraint.activate([
            informationStack.topAnchor.constraint(equalTo: exerciseArea.topAnchor, constant: 8),
            informationStack.centerXAnchor.constraint(equalTo: exerciseArea.centerXAnchor),
            answerField.centerYAnchor.constraint(equalTo: exerciseArea.centerYAnchor),
            answerField.centerXAnchor.constraint(equalTo: exerciseArea.centerXAnchor),
        ])
    }
    
    private func submit() {
        view.endEditing(true)
        if let submitButton {
            submitButton.isHidden = true
        }
        guard let answer = answerField.cleanedText else { return }
        let result = viewModel.calculateResult(answer)
        completionDelegate?.grade(result: result)

        // Take the users inputed answer then compare it to the actual answer while bolding and underlining incorrect letters
        let attributedAnswer = result.grade != .correct
            ? NSAttributedString.highlightedAnswer(from: viewModel.cleanAnswerInput(answer), wordForm: viewModel.wordForm)
            : nil
        
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
    private func didEditInputField() {
        guard let submitButton else { return }
        guard let inputText = answerField.cleanedText else { return }
        
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
}
