import UIKit

class WordEndingMultipleChoiceView : MultipleChoiceExerciseViewController {
    private let viewModel: WordEndingMultipleChoiceExerciseViewModel
    
    init(viewModel: WordEndingMultipleChoiceExerciseViewModel) {
        self.viewModel = viewModel
        
        super.init(
            banner: ExerciseBanner(text: "Choose the word with the correct ending"),
            submitButton: SubmitButton(),
            completionBanner: ExerciseCompletionBanner()
        )
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
        
        multipleChoiceGroup.setChoices(choiceData: viewModel.wordFormChoices)
        
        let informationStack = WordEndingInformationView(accentedWord: viewModel.accentedBaseFormText, wordFormText: viewModel.correctWordFormText)
        exerciseArea.addSubview(informationStack)
        exerciseArea.addSubview(multipleChoiceGroup)
        
        multipleChoiceGroup.delegate = self

        if let submitButton {
            submitButton.setClickHandler(onSubmit: onSubmit)
        }
        
        NSLayoutConstraint.activate([
            informationStack.topAnchor.constraint(equalTo: exerciseArea.topAnchor, constant: 8),
            informationStack.centerXAnchor.constraint(equalTo: exerciseArea.centerXAnchor)
        ])
    }
    
    private func onSubmit() {
        guard let completionBanner else { return }
        
        let result = viewModel.calculateResult(isTheCorrectButtonChosen)
        let attributedAnswer = result.grade == .incorrect ? NSAttributedString(string: viewModel.correctWordForm.bare) : nil
        completionDelegate?.grade(result: result)
        completionBanner.open(exerciseResult: result, actualAnswer: attributedAnswer) { [weak self] in
            self?.completionDelegate?.next()
        }
    }
}
