final class StressChoiceExerciseFactory: ExerciseFactory {
    let word: Word
    var attempts: Int
    let incorrectStressedWordChoices: [String]
    private let wordService: WordService
    
    init(word: Word, wordService: WordService) {
        self.word = word
        self.attempts = 0
        self.wordService = wordService
        self.incorrectStressedWordChoices = Self.createIncorrectStressedWordChoices(for: word, wordService: wordService)
    }
    
    func createExercise() -> (any Exercise)? {
        return StressChoiceExerciseView(
            viewModel: StressChoiceExerciseViewModel(word: word, wordService: wordService, incorrectStressVariations: incorrectStressedWordChoices)
        )
    }

    /// Find all the possible stress variation except for the actual stressed variation, will ignore the letter ё
    /// - Parameters:
    ///   - word: The word we will find stressed vowel variations in
    ///   - wordService: Since this is a static method, we will need to supply the WordService
    ///
    /// - Returns: A list of strings, which are the stressed vowel varations excluding the correct stressed vowel variation
    private static func createIncorrectStressedWordChoices(for word: Word, wordService: WordService) -> [String] {
        var accentedVariations = [String]()
        let bareWord = Array(word.bare)
        for i in 0..<word.bare.count {
            if wordService.isVowel(letter: bareWord[i]) {
                if bareWord[i] != "ё" { // eyo is always stressed so just don't add it to the list
                    let accentedLetterIndex = word.bare.index(word.bare.startIndex, offsetBy: i + 1)
                    var accentedWord = word.bare
                    accentedWord.insert("'", at: accentedLetterIndex)
                    accentedVariations.append(accentedWord)
                }
            }
        }

        // While return we will loop thru the word and remove the instance that is the same as the actual stressed variation
        return accentedVariations.filter({ $0 != word.accented})
    }
}
