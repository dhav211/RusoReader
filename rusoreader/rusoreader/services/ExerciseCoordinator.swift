class ExerciseCoordinator {
    private var exercises = [ExerciseFactory]()
    private let dictionaryService: DictionaryService
    private let wordService: WordService
    private let sentenceService: SentenceService
    private let onLoadNextExercise: () -> Void
    private let onShowSummary: () -> Void
    
    init(dictionaryService: DictionaryService, wordService: WordService, sentenceService: SentenceService, onLoadNextExercise: @escaping () -> Void, onShowSummary: @escaping () -> Void) {
        self.dictionaryService = dictionaryService
        self.wordService = wordService
        self.sentenceService = sentenceService
        self.onLoadNextExercise = onLoadNextExercise
        self.onShowSummary = onShowSummary
        self.exercises = createExerciseFactories()
    }
    
    
    /// Pop the first exercise factory from the exercise array and from here we will turn it into an exercise view controller
    var nextExercise: Exercise? {
        guard let exerciseFactory = exercises.first else { return nil}
        var exercise = exerciseFactory.createExercise()
        exercise.completionDelegate = self
        return exercise
    }
    
    /// Create exercises on 10 words, this will create the factories, which hold all the information to create the exercise view controllers
    /// - Returns: A list of exercise factories which will create the exercise view controllers as they are removed from the list
    private func createExerciseFactories() -> [ExerciseFactory] {
        let dictionarySize: Int = dictionaryService.count >= 10 ? 10 : dictionaryService.count - 1
        let exerciseWords = dictionaryService.getAllWords().shuffled()[0..<dictionarySize]
        
        return exerciseWords.compactMap { word in
            if !word.translations.isEmpty {
                let sentence = sentenceService.findSingleSentence(by: word.id)

                return FlashcardFactory(
                    word: word,
                    sentence: sentence?.text ?? "",
                    flashcardExerciseViewModel: FlashcardExerciseViewModel(word: word, sentence: sentence?.text ?? "", wordService: wordService, sentenceService: sentenceService)
                )
            }
            return nil
        }
    }
}

extension ExerciseCoordinator: CompletedExerciseDelegate {
    func grade(result: ExerciseResult) {
        switch result.grade {
        case .correct:
            exercises.removeFirst()
            dictionaryService.updateWordScore(word: result.word, by: result.score)
            
        case .incorrect:
            let exercise = exercises.removeFirst()
            dictionaryService.updateWordScore(word: result.word, by: result.score)
            exercises.append(exercise)
            
        case .almost:
            let exercise = exercises.removeFirst()
            exercises.append(exercise)
        }
        
        if exercises.isEmpty {
            onShowSummary()
        } else {
            onLoadNextExercise()
        }
    }
}
