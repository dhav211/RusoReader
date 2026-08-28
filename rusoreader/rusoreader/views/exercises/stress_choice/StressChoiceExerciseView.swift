import UIKit

class StressChoiceExerciseView : UIViewController, Exercise, MultipleChoiceButtonGroupDelegate {
    private let viewModel: StressChoiceExerciseViewModel
    private let banner: ExerciseBanner
    private let exerciseArea: UIView
    private let playSound: PlaySoundView
    private let multipleChoiceGroup: MultipleChoiceButtonGroup
    private let submitButton: SubmitButton
    private let completionBanner: ExerciseCompletionBanner
    private var orientation: PhoneOrientation = .portrait
    
    weak var completionDelegate: CompletedExerciseDelegate?

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
        self.banner = ExerciseBanner(text: "Choose the correct stress variation")
        self.exerciseArea = UIView()
        self.submitButton = SubmitButton()
        self.completionBanner = ExerciseCompletionBanner()
        self.playSound = PlaySoundView(textToSpeak: viewModel.correctStressedForm)
        self.multipleChoiceGroup = MultipleChoiceButtonGroup(
            choiceData: viewModel.stressedWordChoices.map { choice in
                return MultipleChoiceButtonData(buttonText: choice.1, isCorrect: choice.0 == viewModel.word.accented)
            }
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        orientation = PhoneOrientation.set(isViewInPortrait: size.height > size.width)
        setInteractiveElementConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("exerciseArea:", exerciseArea.frame)
        print("multipleChoiceGroup:", multipleChoiceGroup.frame)
        print("playSound:", playSound.frame)
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        orientation = PhoneOrientation.set(isViewInPortrait: traitCollection.verticalSizeClass == .regular &&
                              traitCollection.horizontalSizeClass == .compact)
        
        exerciseArea.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(banner)
        view.addSubview(exerciseArea)
        addChild(completionBanner)
        view.addSubview(completionBanner.view)
        view.addSubview(submitButton)
        completionBanner.didMove(toParent: self)

        let multipleChoiceGroupWidth = min((UIScreen.main.bounds.width) * 0.75, 300)
        exerciseArea.addSubview(playSound)
        exerciseArea.addSubview(multipleChoiceGroup)
        multipleChoiceGroup.delegate = self
        setInteractiveElementConstraints()

        submitButton.setClickHandler(onSubmit: onSubmit)
        
        NSLayoutConstraint.activate([
            banner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            banner.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            banner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            exerciseArea.topAnchor.constraint(equalTo: banner.bottomAnchor),
            exerciseArea.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            exerciseArea.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            exerciseArea.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            playSound.widthAnchor.constraint(equalToConstant: 64),
            playSound.heightAnchor.constraint(equalToConstant: 64),
            multipleChoiceGroup.widthAnchor.constraint(equalToConstant: multipleChoiceGroupWidth),
            submitButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32),
            submitButton.widthAnchor.constraint(equalToConstant: multipleChoiceGroupWidth),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            completionBanner.view.heightAnchor.constraint(equalToConstant: 200),
            completionBanner.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            completionBanner.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            completionBanner.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func onMultipleChoiceButtonSelected(isCorrect: Bool) {
        viewModel.isTheCorrectButtonChosen = isCorrect
        submitButton.enable()
    }
    
    private func onSubmit() {
        let result = viewModel.calculateResult(viewModel.isTheCorrectButtonChosen)
        let attributedAnswer = result.grade == .incorrect ? NSAttributedString(string: viewModel.correctStressedForm) : nil
        completionDelegate?.grade(result: result)
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
