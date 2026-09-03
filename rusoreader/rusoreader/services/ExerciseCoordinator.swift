import Foundation

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

        self.exercises =  Self.createExerciseFactories(
            exerciseWords: dictionaryService.wordsForExercise(), 
            sentenceService: sentenceService, 
            wordService: wordService
        )
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
    static func createExerciseFactories(exerciseWords: [ExerciseWord], sentenceService: SentenceService, wordService: WordService) -> [ExerciseFactory] {
        var rounds = Array(repeating: [ExerciseFactory](), count: 3)

        for exerciseWord in exerciseWords {
            let factories: [ExerciseFactory] = {
                switch exerciseWord.userLevel {
                    case .new:
                    return createExercisesForNew(exerciseWord: exerciseWord, sentenceService: sentenceService, wordService: wordService)
    
                    case .unfamiliar:
                    return createExercisesForNew(exerciseWord: exerciseWord, sentenceService: sentenceService, wordService: wordService)
    
                    case .familiar:
                    return createExercisesForNew(exerciseWord: exerciseWord, sentenceService: sentenceService, wordService: wordService)
    
                    case .fluent:
                    return createExercisesForNew(exerciseWord: exerciseWord, sentenceService: sentenceService, wordService: wordService)
                }
            }()

            for i in 0..<factories.count {
            if (i > 2) { break } // the rounds array only has 3 indices
               rounds[i].append(factories[i]) 
            }
        }
        
//         return exerciseWords.compactMap { word in
//             // uncomment this when we are ready to reimplement flash cards
//             // we will have a spaced repetion algorithm that will choose the words and the exercises
//             // right now we are just testing the exercises themselves
// //            if !word.translations.isEmpty {
// //                let sentence = sentenceService.findSingleSentence(by: word.id)
// //
// //                return FlashcardFactory(
// //                    word: word,
// //                    sentence: sentence?.text ?? "",
// //                    flashcardExerciseViewModel: FlashcardExerciseViewModel(word: word, sentence: sentence?.text ?? "", wordService: wordService, sentenceService: sentenceService)
// //                )
// //            }
//             // if word.type != .adverb || word.type != .other { this is for word ending exercises
//             if wordService.hasMultipleVowels(word) {
//                 return StressChoiceExerciseFactory(word: word, wordService: wordService)
//             }
//             return nil
//         }
        return rounds[0].shuffled() + rounds[1].shuffled() + rounds[2].shuffled()
    }

    static private func createExercisesForNew(exerciseWord: ExerciseWord, sentenceService: SentenceService, wordService: WordService) -> [ExerciseFactory] {
        var factories = [ExerciseFactory]()
        if !exerciseWord.word.translations.isEmpty {
            let sentence = sentenceService.findSingleSentence(by: exerciseWord.word.id)
            factories.append(
                FlashcardFactory(
                    word: exerciseWord.word,
                    sentence: sentence?.text ?? "",
                    flashcardExerciseViewModel: FlashcardExerciseViewModel(
                        word: exerciseWord.word, 
                        sentence: sentence?.text ?? "", 
                        wordService: wordService, 
                        sentenceService: sentenceService
                    )
                )
            )
        }
        if exerciseWord.word.type != .adverb && exerciseWord.word.type != .other {
            factories.append(
                WordEndingMultipleChoiceFactory(
                    word: exerciseWord.word, 
                    wordService: wordService
                )
            )
        }

        return factories
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
            let exercise = exercises.removeFirst()

            if exercise.attempts == 0 { // On the first attempt we will set the new due date     
                dictionaryService.update(
                    word: result.word, 
                    scoreChangeAmount: result.score, 
                    newDueDate: addDaysToTodaysDate(
                        numberOfDays: dictionaryService.daysUntilNextDueDate(
                            wordId: result.word.id, 
                            exerciseScoreAmount: result.score
                        )
                    )
                )
            } else { // On the second and up attempts we have already set the new due date
                dictionaryService.updateScore(word: result.word, scoreChangeAmount: result.score)
            }
            
        case .incorrect, .almost:
            var exercise = exercises.removeFirst()

            if exercise.attempts <= 1 { // We won't don't need to punish the player for getting it wrong more than once
                dictionaryService.update(
                    word: result.word, 
                    scoreChangeAmount: result.score, 
                    newDueDate: addDaysToTodaysDate(
                        numberOfDays: dictionaryService.daysUntilNextDueDate(
                            wordId: result.word.id, 
                            exerciseScoreAmount: result.score
                        )
                    )
                )
            } else { // Update the times  appeared variable only, as this isn't a direct punishment but will have effect on due date generation
                dictionaryService.increaseTimesAppeared(word: result.word)
            }

            exercise.attempts += 1
            exercises.append(exercise)

        case .error: // Rarely if ever should hit here, but just move past the exercise without updating the score
            exercises.removeFirst()
        }
    }

    private func addDaysToTodaysDate(numberOfDays: Int) -> Date {
        return Date.now + TimeInterval(60 * 60 * numberOfDays)
    }
}
