import UIKit

class StressChoiceExerciseView : MultipleChoiceExerciseViewController, MultipleChoiceButtonGroupDelegate {
    private let viewModel: StressChoiceExerciseViewModel
    private let playSound: PlaySoundView
    private var orientation: PhoneOrientation = .portrait

    private lazy var portraitConstraints = [
        multipleChoiceGroup.centerXAnchor.constraint(equalTo: exerciseArea.centerXAnchor),
        multipleChoiceGroup.centerYAnchor.constraint(equalTo: exerciseArea.centerYAnchor, constant: 64),
        playSound.centerXAnchor.constraint(equalTo: exerciseArea.centerXAnchor),
        playSound.bottomAnchor.constraint(equalTo: multipleChoiceGroup.topAnchor, constant: -64)
    ]

    private lazy var landscapeContraints = [
        multipleChoiceGroup.centerYAnchor.constraint(equalTo: exerciseArea.centerYAnchor),
        multipleChoiceGroup.centerXAnchor.constraint(equalTo: exerciseArea.centerXAnchor, constant: 64),
        playSound.centerYAnchor.constraint(equalTo: exerciseArea.centerYAnchor),
        playSound.trailingAnchor.constraint(equalTo: multipleChoiceGroup.leadingAnchor, constant: -64)
    ]
    
    init(viewModel: StressChoiceExerciseViewModel) {
        self.viewModel = viewModel
        self.playSound = PlaySoundView(textToSpeak: viewModel.correctStressedForm)
        
        super.init(
            banner: ExerciseBanner(text: "Choose the correct stress variation"),
            multipleChoiceGroup: MultipleChoiceButtonGroup(),
            submitButton: SubmitButton(),
            completionBanner: ExerciseCompletionBanner()
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        orientation = PhoneOrientation.set(isViewInPortrait: size.height > size.width)
        setInteractiveElementConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func setup() {
        super.setup()
        
        view.backgroundColor = .systemBackground
        orientation = PhoneOrientation.set(isViewInPortrait: traitCollection.verticalSizeClass == .regular &&
                              traitCollection.horizontalSizeClass == .compact)
        
        exerciseArea.translatesAutoresizingMaskIntoConstraints = false
        
        multipleChoiceGroup.setChoices(
            choiceData: viewModel.stressedWordChoices.map { choice in
                return MultipleChoiceButtonData(buttonText: choice.1, isCorrect: choice.0 == viewModel.word.accented)
            }
        )

        exerciseArea.addSubview(playSound)
        multipleChoiceGroup.delegate = self
        setInteractiveElementConstraints()

        if let submitButton {
            submitButton.setClickHandler(onSubmit: onSubmit)
        }
        
        NSLayoutConstraint.activate([
            playSound.widthAnchor.constraint(equalToConstant: 64),
            playSound.heightAnchor.constraint(equalToConstant: 64),
        ])
    }

    func onMultipleChoiceButtonSelected(isCorrect: Bool) {
        viewModel.isTheCorrectButtonChosen = isCorrect
        if let submitButton {
            submitButton.enable()
        }
    }
    
    private func onSubmit() {
        let result = viewModel.calculateResult(viewModel.isTheCorrectButtonChosen)
        let attributedAnswer = result.grade == .incorrect ? NSAttributedString(string: viewModel.correctStressedForm) : nil
        completionDelegate?.grade(result: result)
        guard let completionBanner else { return }
        completionBanner.open(exerciseResult: result, actualAnswer: attributedAnswer) { [weak self] in
            self?.completionDelegate?.next()
        }
    }

    private func setInteractiveElementConstraints() {


        switch orientation {
            case .portrait:
                landscapeContraints.forEach({ $0.isActive = false })
                portraitConstraints.forEach({ $0.isActive = true })
            case .landscape:
                portraitConstraints.forEach({ $0.isActive = false })
                landscapeContraints.forEach({ $0.isActive = true })
            case .error:
                return
        }
    }
}
