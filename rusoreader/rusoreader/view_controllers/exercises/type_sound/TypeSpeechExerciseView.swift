import UIKit

final class TypeSpeechExerciseView: ExerciseViewController, UITextFieldDelegate {
    private let viewModel: TypeSpeechExerciseViewModel
    private let inputStack: UIStackView
    private let playSound: PlaySoundView
    private let answerField: AnswerTextFieldView
    private let showHint: UIButton
    private let hint: UILabel
    
    
    init(viewModel: TypeSpeechExerciseViewModel, speechSynth: SpeechSynth) {
        self.viewModel = viewModel
        self.inputStack = UIStackView()
        self.answerField = AnswerTextFieldView()
        self.playSound = PlaySoundView(textToSpeak: viewModel.spokenText, speechSynth: speechSynth)
        self.showHint = UIButton()
        self.hint = UILabel()
        
        super.init(
            banner: ExerciseBanner(text: "Write the word hear in the audio"),
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        setInteractiveElementConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func setup() {
        super.setup()
        
        answerField.setup(
            width: min((UIScreen.main.bounds.width) * 0.75, 300),
            onEdited: { [weak self] in self?.didEditInputField() }
        )
        
        answerField.delegate = self
        
        showHint.setTitle("Show Hint", for: .normal)
        showHint.setTitleColor(.label, for: .normal)
        showHint.addTarget(self, action: #selector(onShowHintTapped), for: .touchUpInside)
        
        setupInputStack()
        inputStack.addArrangedSubview(showHint)
        inputStack.addArrangedSubview(playSound)
        inputStack.addArrangedSubview(answerField)
        
        setInteractiveElementConstraints()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        view.backgroundColor = .systemBackground
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
            ? NSAttributedString.highlightedAnswer(from: viewModel.cleanAnswerInput(answer), wordForm: viewModel.answerWordForm)
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
    
    @objc private func onShowHintTapped() {
        inputStack.removeArrangedSubview(showHint)
        inputStack.insertArrangedSubview(hint, at: 0)
        showHint.removeFromSuperview()
        hint.text = viewModel.hint
    }
    
    private func setupInputStack() {
        inputStack.axis = .vertical
        inputStack.alignment = .center
        inputStack.spacing = 4
        inputStack.translatesAutoresizingMaskIntoConstraints = false
        exerciseArea.addSubview(inputStack)
        
        // We add a layout guide so we can center the input stack between the top of the exercise area and the top of the submit button
        let centeringGuide = UILayoutGuide()
        view.addLayoutGuide(centeringGuide)
        guard let submitButton else { return }
        
        NSLayoutConstraint.activate([
            centeringGuide.topAnchor.constraint(equalTo: exerciseArea.topAnchor, constant: -12),
            centeringGuide.bottomAnchor.constraint(equalTo: submitButton.topAnchor),
            centeringGuide.leadingAnchor.constraint(equalTo: exerciseArea.leadingAnchor),
            centeringGuide.trailingAnchor.constraint(equalTo: exerciseArea.trailingAnchor),
            inputStack.centerXAnchor.constraint(equalTo: centeringGuide.centerXAnchor),
            inputStack.centerYAnchor.constraint(equalTo: centeringGuide.centerYAnchor)
        ])
    }
    
    private func setInteractiveElementConstraints() {
        // when the screen orientation is changed we should check if the play sound button should be resized so we don't overflow into the answer text field
        playSound.setSize(UIScreen.main.bounds.height > 375 ? 128 : 72)
    }
}
