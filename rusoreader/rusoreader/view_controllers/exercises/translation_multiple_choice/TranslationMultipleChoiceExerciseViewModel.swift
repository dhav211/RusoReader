final class TranslationMultipleChoiceExerciseViewModel: ExerciseViewModel {
    let word: Word
    let translationChoices: [MultipleChoiceButtonData]
    let questionWord: String
    
    init(word: Word, questionWord: String, translationChoices: [(String, Int)]) {
        self.word = word
        self.questionWord = questionWord
        self.translationChoices = translationChoices.map { choice in
            return MultipleChoiceButtonData(buttonText: choice.0, isCorrect: choice.1 == word.id)
        }
    }
    
    func calculateResult(_ answer: Bool) -> ExerciseResult {
        if answer {
            return ExerciseResult(word: word, grade: .correct, score: -0.5)
        } else {
            return ExerciseResult(word: word, grade: .incorrect, score: 0.5)
        }
    }
}
