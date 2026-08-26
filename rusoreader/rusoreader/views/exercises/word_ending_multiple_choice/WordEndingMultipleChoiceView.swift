import UIKit

class WordEndingMultipleChoiceView : UIViewController, Exercise, MultipleChoiceButtonGroupDelegate {
    private let viewModel: WordEndingMultipleChoiceExerciseViewModel
    private let banner: ExerciseBanner
    private let exerciseArea: UIView
    private let multipleChoiceGroup: MultipleChoiceButtonGroup
    private let submitButton: SubmitButton
    private let completionBanner: ExerciseCompletionBanner
    
    weak var completionDelegate: CompletedExerciseDelegate?
    
    init(viewModel: WordEndingMultipleChoiceExerciseViewModel) {
        self.viewModel = viewModel
        self.banner = ExerciseBanner(text: "Choose the word with the correct ending")
        self.exerciseArea = UIView()
        self.submitButton = SubmitButton()
        self.completionBanner = ExerciseCompletionBanner()
        self.multipleChoiceGroup = MultipleChoiceButtonGroup(
            choiceData: viewModel.wordFormChoices.map { choice in
                return MultipleChoiceButtonData(buttonText: choice, isCorrect: choice == viewModel.correctWordForm.bare)
            }
        )
        super.init(nibName: nil, bundle: nil)
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
        view.addSubview(submitButton)
        completionBanner.didMove(toParent: self)
        
        let informationStack = WordEndingInformationView(accentedWord: viewModel.accentedBaseFormText, wordFormText: viewModel.correctWordFormText)
        exerciseArea.addSubview(informationStack)
        exerciseArea.addSubview(multipleChoiceGroup)
        
        let multipleChoiceGroupWidth = min((UIScreen.main.bounds.width) * 0.75, 300)
        multipleChoiceGroup.delegate = self

        submitButton.setClickHandler(onSubmit: onSubmit)
        
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
            multipleChoiceGroup.widthAnchor.constraint(equalToConstant: multipleChoiceGroupWidth),
            multipleChoiceGroup.centerYAnchor.constraint(equalTo: exerciseArea.centerYAnchor),
            multipleChoiceGroup.centerXAnchor.constraint(equalTo: exerciseArea.centerXAnchor),
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
        let attributedAnswer = result.grade == .incorrect ? NSAttributedString(string: viewModel.correctWordForm.bare) : NSAttributedString(string: "")
        completionDelegate?.grade(result: result)
        completionBanner.open(exerciseResult: result, actualAnswer: attributedAnswer) { [weak self] in
            self?.completionDelegate?.next()
        }
    }
}
