class FlashcardFactory: ExerciseFactory {
    var attempts: Int
    let word: Word
    let flashcardExerciseViewModel: FlashcardExerciseViewModel
    let speechSynth: SpeechSynth
    
    init(word: Word, sentence: String, flashcardExerciseViewModel: FlashcardExerciseViewModel, speechSynth: SpeechSynth) {
        self.word = word
        self.attempts = 0
        self.flashcardExerciseViewModel = flashcardExerciseViewModel
        self.speechSynth = speechSynth
    }
    
    func createExercise() -> ExerciseViewController? {
        return FlashcardExerciseView(viewModel: flashcardExerciseViewModel, speechSynth: speechSynth)
    }
}
