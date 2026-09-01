enum ExerciseCoordinatorError: Error {
    case incorrectWordAmountInDictionary
}

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
        do {
            self.exercises = try createExerciseFactories()
        } catch {
            self.exercises = [ExerciseFactory]()
        }
    }
    
    
    /// Pop the first exercise factory from the exercise array and from here we will turn it into an exercise view controller
    var nextExercise: Exercise? {
        guard let exerciseFactory = exercises.first else { return nil}
        guard var exercise = exerciseFactory.createExercise() else { return nil }
        exercise.completionDelegate = self
        return exercise
    }
    
    /// Create exercises on 10 words, this will create the factories, which hold all the information to create the exercise view controllers
    /// - Returns: A list of exercise factories which will create the exercise view controllers as they are removed from the list
    private func createExerciseFactories() throws -> [ExerciseFactory] {
        if dictionaryService.count == 0 {
            throw ExerciseCoordinatorError.incorrectWordAmountInDictionary
        }
        
        let dictionarySize: Int = dictionaryService.count >= 10 ? 10 : dictionaryService.count
        let allWords = dictionaryService.getAllWords()

        if allWords.count < dictionarySize {
            throw ExerciseCoordinatorError.incorrectWordAmountInDictionary
        }
        
        let exerciseWords = allWords.shuffled()[0..<dictionarySize]
        
        return exerciseWords.compactMap { word in
            // uncomment this when we are ready to reimplement flash cards
            // we will have a spaced repetion algorithm that will choose the words and the exercises
            // right now we are just testing the exercises themselves
//            if !word.translations.isEmpty {
//                let sentence = sentenceService.findSingleSentence(by: word.id)
//
//                return FlashcardFactory(
//                    word: word,
//                    sentence: sentence?.text ?? "",
//                    flashcardExerciseViewModel: FlashcardExerciseViewModel(word: word, sentence: sentence?.text ?? "", wordService: wordService, sentenceService: sentenceService)
//                )
//            }
            // if word.type != .adverb || word.type != .other { this is for word ending exercises
            if wordService.hasMultipleVowels(word) {
                return StressChoiceExerciseFactory(word: word, wordService: wordService)
            }
            return nil
        }
    }
}

extension ExerciseCoordinator: CompletedExerciseDelegate {
    func next() {
        if exercises.isEmpty {
            onShowSummary()
        } else {
            onLoadNextExercise()
        }
    }
    
    func grade(result: ExerciseResult) {
        switch result.grade {
        case .correct:
            exercises.removeFirst()
            dictionaryService.update(word: result.word, by: result.score)
            
        case .incorrect:
            let exercise = exercises.removeFirst()
            dictionaryService.update(word: result.word, by: result.score)
            exercises.append(exercise)
            
        case .almost:
            let exercise = exercises.removeFirst()
            exercises.append(exercise)

        case .error: // Rarely if ever should hit here, but just move past the exercise without updating the score
            exercises.removeFirst()
        }
    }
}
