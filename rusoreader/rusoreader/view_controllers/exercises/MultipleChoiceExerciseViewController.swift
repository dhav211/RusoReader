import UIKit

class MultipleChoiceExerciseViewController: ExerciseViewController {
    public var multipleChoiceGroup: MultipleChoiceButtonGroup
    
    init(
        banner: ExerciseBanner,
        multipleChoiceGroup: MultipleChoiceButtonGroup = MultipleChoiceButtonGroup(),
        submitButton: SubmitButton? = nil,
        completionBanner: ExerciseCompletionBanner? = nil
    ) {
        self.multipleChoiceGroup = multipleChoiceGroup
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
}
