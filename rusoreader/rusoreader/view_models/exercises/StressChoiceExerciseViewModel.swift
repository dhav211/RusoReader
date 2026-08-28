 final class StressChoiceExerciseViewModel: ExerciseViewModel {
     let word: Word
     let stressedWordChoices: [(String, String)] // In the tuple the first element as the ' indicating stressed, and the second element is the built in stress mark
     var isTheCorrectButtonChosen: Bool
     private let wordService: WordService

    init(word: Word, wordService: WordService, incorrectStressVariations: [String]) {
        let numberOfIncorrectVariations = min(3, incorrectStressVariations.count)
        let combinedChoices = Array(incorrectStressVariations.sorted()[0..<numberOfIncorrectVariations]) + [word.accented]
        self.word = word
        self.stressedWordChoices = combinedChoices.sorted().map { return ($0, wordService.addStress(to: $0)) }
        self.isTheCorrectButtonChosen = false
        self.wordService = wordService
    }

    /// The button data from the selected multiple choice button
    /// - Parameter answer: A boolean value where true is correct and false is incorrect
    /// - Returns: An exercise result with the grade and the score
    func calculateResult(_ answer: Bool) -> ExerciseResult {
        if answer {
            return ExerciseResult(word: word, grade: .correct, score: -0.25)
        } else {
            return ExerciseResult(word: word, grade: .incorrect, score: 0.25)
        }
    }

    var correctStressedForm: String {
        return wordService.addStress(to: word.accented)
    }
 }
