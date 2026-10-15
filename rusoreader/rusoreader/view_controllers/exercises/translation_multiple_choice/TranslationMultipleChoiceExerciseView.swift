import UIKit

class TranslationMultipleChoiceExerciseView: MultipleChoiceExerciseViewController {
    private let viewModel: TranslationMultipleChoiceExerciseViewModel
    
    init(viewModel: TranslationMultipleChoiceExerciseViewModel) {
        self.viewModel = viewModel
        
        super.init(
            banner: ExerciseBanner(text: "Choose the correct translation"),
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
        
        multipleChoiceGroup.setChoices(choiceData: viewModel.translationChoices)
        
        // This is the word the user will need to choose the correct translation for
        let wordLabel = UILabel()
        wordLabel.font = .preferredFont(forTextStyle: .headline)
        wordLabel.text = viewModel.questionWord
        wordLabel.translatesAutoresizingMaskIntoConstraints = false
        
        exerciseArea.addSubview(wordLabel)
        exerciseArea.addSubview(multipleChoiceGroup)
        
        multipleChoiceGroup.delegate = self

        if let submitButton {
            submitButton.setClickHandler(onSubmit: onSubmit)
        }
        
        NSLayoutConstraint.activate([
            wordLabel.topAnchor.constraint(equalTo: exerciseArea.topAnchor, constant: 8),
            wordLabel.centerXAnchor.constraint(equalTo: exerciseArea.centerXAnchor)
        ])
    }
    
    private func onSubmit() {
        guard let completionBanner else { return }
        
        let result = viewModel.calculateResult(isTheCorrectButtonChosen)
        //let attributedAnswer = result.grade == .incorrect ? NSAttributedString(string: viewModel.correctWordForm.bare) : nil
        completionDelegate?.grade(result: result)
        completionBanner.open(exerciseResult: result, actualAnswer: nil) { [weak self] in
            self?.completionDelegate?.next()
        }
    }
}
