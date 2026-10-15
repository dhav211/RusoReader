final class TranslationMultipleChoiceExerciseFactory: ExerciseFactory {
    let word: Word
    var attempts: Int
    let questionWord: String
    let translationChoices: [(String, Int)]
    
    init(word: Word, dictionaryService: DictionaryService, wordService: WordService) {
        self.word = word
        self.attempts = 0
        
        // Look through the user's dictionary and see if we can find 2 words of the same type
        var randomChoices = dictionaryService
            .getRandomWords(10)
            .filter({ $0.id != word.id && !$0.translations.isEmpty && $0.type == word.type })
            .shuffled()
        
        // If we can't then lets just choose 2 random ones from the database, they may happen early on in the apps life span for the user
        if randomChoices.count < 2 {
            randomChoices = wordService
                .findRandom(by: word.type, limit: 15)
                .filter({ $0.id != word.id && !$0.translations.isEmpty && $0.type == word.type })
                .shuffled()
        }

        // This may be redudnant but lets make sure we never hit an out of bounds error with our choice
        let safeChoiceIndex = min(2, randomChoices.count)
        
        // The choices array be used temporarily because will will need to append the real answer to it after we have chosen the random incorrect ones
        var choices = [(String, Int)]()
        if Bool.random() { // True the question word is english and the choices are russian
            self.questionWord = word.translationText
            
            // Choose the first two (or at least up to the first two) choices and add them to a tuple that will be used to create the MultipleChoiceData
            choices = randomChoices[0..<safeChoiceIndex].map { choice in
                return (wordService.addStress(to: choice.accented), choice.id)
            }
            choices.append((wordService.addStress(to: word.accented), word.id))
            choices.shuffle()
        } else { // False then the opposite happens
            self.questionWord = wordService.addStress(to: word.accented)
            
            // This is the same as above but instead of the word form we will choose the random word's first translation
            choices = randomChoices[0..<safeChoiceIndex].map { choice in
                return (choice.firstTranslation, choice.id)
            }
            choices.append((word.firstTranslation, word.id))
            choices.shuffle()
        }
        
        self.translationChoices = choices
    }
    
    func createExercise() -> ExerciseViewController? {
        return TranslationMultipleChoiceExerciseView(
            viewModel: TranslationMultipleChoiceExerciseViewModel(
                word: word, questionWord: questionWord, translationChoices: translationChoices)
        )
    }
}
