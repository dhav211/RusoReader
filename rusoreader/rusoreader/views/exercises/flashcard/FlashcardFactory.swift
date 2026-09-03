class FlashcardFactory: ExerciseFactory {
    var attempts: Int
    let word: Word
    let flashcardExerciseViewModel: FlashcardExerciseViewModel
    
    init(word: Word, sentence: String, flashcardExerciseViewModel: FlashcardExerciseViewModel) {
        self.word = word
        self.attempts = 0
        self.flashcardExerciseViewModel = flashcardExerciseViewModel
    }
    
    func createExercise() -> (any Exercise)? {
        return FlashcardExerciseView(viewModel: flashcardExerciseViewModel)
    }
}
