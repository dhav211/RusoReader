import UIKit

protocol MultipleChoiceButtonGroupDelegate : AnyObject {
    func onMultipleChoiceButtonSelected(isCorrect: Bool)
}

final class MultipleChoiceButtonGroup: UIStackView {
    let choices: [MultipleChoiceButton]
    var currentSelectedButton: MultipleChoiceButton?
    weak var delegate: MultipleChoiceButtonGroupDelegate?

    init(choiceData: [MultipleChoiceButtonData]) {
        self.choices = choiceData.map { data in
            return MultipleChoiceButton(buttonText: data.buttonText, isCorrect: data.isCorrect)
        }

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        spacing = 8

        for choice in choices {
            choice.setClickHandler { [weak self] in
                self?.manageButtonStates(choice)
            }
            addArrangedSubview(choice)
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// When a button is clicked a previous one will need be deactived and the currently clicked one will then become the selected. Any exercise that
    /// has a multiple choice button group will need to implement the proper delegate to enable the submit button when a multiple choice button is clicked.
    /// - Parameter clickedButton: The multiple choice button that will become the currentSelectedButton
    private func manageButtonStates(_ clickedButton: MultipleChoiceButton) {
        if let previousButton = currentSelectedButton {
            previousButton.deactivate()
        }

        currentSelectedButton = clickedButton
        delegate?.onMultipleChoiceButtonSelected(isCorrect: clickedButton.isCorrect)
    }
}