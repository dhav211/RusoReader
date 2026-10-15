import UIKit

class MultipleChoiceExerciseViewController: ExerciseViewController, MultipleChoiceButtonGroupDelegate {
    public var multipleChoiceGroup: MultipleChoiceButtonGroup
    public var isTheCorrectButtonChosen: Bool
    
    init(
        banner: ExerciseBanner,
        multipleChoiceGroup: MultipleChoiceButtonGroup = MultipleChoiceButtonGroup(),
        submitButton: SubmitButton? = nil,
        completionBanner: ExerciseCompletionBanner? = nil
    ) {
        self.multipleChoiceGroup = multipleChoiceGroup
        self.isTheCorrectButtonChosen = false
        super.init(banner: banner, submitButton: submitButton, completionBanner: completionBanner)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setup() {
        super.setup()
        
        let multipleChoiceGroupWidth = min((UIScreen.main.bounds.width) * 0.75, 300)

        multipleChoiceGroup.translatesAutoresizingMaskIntoConstraints = false
        exerciseArea.addSubview(multipleChoiceGroup)

        NSLayoutConstraint.activate([
            multipleChoiceGroup.widthAnchor.constraint(equalToConstant: multipleChoiceGroupWidth),
            multipleChoiceGroup.centerYAnchor.constraint(equalTo: exerciseArea.centerYAnchor),
            multipleChoiceGroup.centerXAnchor.constraint(equalTo: exerciseArea.centerXAnchor),
        ])
    }
    
    /// Called when a multiple choice button is clicked, this will send a boolean value over to determine if the user has selected the correct answer. This function remains the same for every multiple choice exercise.
    /// - Parameter isCorrect: <#isCorrect description#>
    final func onMultipleChoiceButtonSelected(isCorrect: Bool) {
        guard let submitButton else { return }
        isTheCorrectButtonChosen = isCorrect
        submitButton.enable()
    }
}
