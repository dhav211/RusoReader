class WordEndingFactory : ExerciseFactory {
    let word: Word
    let attempts: Int
    var wordForm: WordForm? = nil
    var hasWordForm: Bool { return wordForm != nil }
    private let wordService: WordService
    
    init(word: Word, wordService: WordService) {
        self.word = word
        self.attempts = 0
        self.wordService = wordService
        self.wordForm = RandomWordFormSelector.getRandomWordFormForExercise(from: word)
    }
    
    func createExercise() -> (any Exercise)? {
        guard let wordForm = wordForm else { return nil }
        return WordEndingExerciseView(viewModel: WordEndingExerciseViewModel(word: word, wordForm: wordForm, wordService: wordService))
    }
}
