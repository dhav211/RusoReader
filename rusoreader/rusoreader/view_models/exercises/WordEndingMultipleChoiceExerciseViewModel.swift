 final class WordEndingMultipleChoiceExerciseViewModel: ExerciseViewModel {
     let word: Word
     let correctWordForm: WordForm
     let wordFormChoices: [String]
     var isTheCorrectButtonChosen: Bool
     private let wordService: WordService

    init(word: Word, correctWordForm: WordForm, wordFormChoices: [String], wordService: WordService) {
         self.word = word
         self.correctWordForm = correctWordForm
         self.wordFormChoices = wordFormChoices
         self.wordService = wordService
         self.isTheCorrectButtonChosen = false
    }

    /// The button data from the selected multiple choice button
    /// - Parameter answer: A boolean value where true is correct and false is incorrect
    /// - Returns: An exercise result with the grade and the score
    func calculateResult(_ answer: Bool) -> ExerciseResult {
        if answer {
            return ExerciseResult(word: word, grade: .correct, score: -0.5)
        } else {
            return ExerciseResult(word: word, grade: .incorrect, score: 0.5)
        }
    }

    var accentedBaseFormText: String {
         return wordService.addStress(to: word.accented)
    }

    var correctWordFormText: String {
         return correctWordForm.formText
    }
 }
