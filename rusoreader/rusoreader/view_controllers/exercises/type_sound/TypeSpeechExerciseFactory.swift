final class TypeSpeechExerciseFactory: ExerciseFactory {
    let word: Word
    let wordForm: WordForm?
    private let wordService: WordService
    private let speechSynth: SpeechSynth
    var attempts: Int
    
    init(word: Word, wordForm: WordForm?, wordService: WordService, speechSynth: SpeechSynth) {
        self.word = word
        self.wordForm = wordForm
        self.wordService = wordService
        self.speechSynth = speechSynth
        self.attempts = 0
    }
    
    func createExercise() -> ExerciseViewController? {
        return TypeSpeechExerciseView(
            viewModel: TypeSpeechExerciseViewModel(
                word: word,
                wordForm: wordForm,
                wordService: wordService
            ),
            speechSynth: speechSynth)
    }
}
