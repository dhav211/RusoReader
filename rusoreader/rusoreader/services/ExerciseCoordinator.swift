import Foundation

enum ExerciseCoordinatorError: Error {
    case incorrectWordAmountInDictionary
}

class ExerciseCoordinator {
    private var exercises = [ExerciseFactory]()
    private let dictionaryService: DictionaryService
    private let wordService: WordService
    private let sentenceService: SentenceService
    private let speechSynth: SpeechSynth
    
    var onLoadNextExercise: (() -> Void)?
    var onShowSummary: (() -> Void)?
    
    init(dictionaryService: DictionaryService, wordService: WordService, sentenceService: SentenceService) {
        self.dictionaryService = dictionaryService
        self.wordService = wordService
        self.sentenceService = sentenceService
        self.speechSynth = SpeechSynth()
    }
    
    
    /// Pop the first exercise factory from the exercise array and from here we will turn it into an exercise view controller
    var nextExercise: Exercise? {
        guard let exerciseFactory = exercises.first else { return nil}
        guard var exercise = exerciseFactory.createExercise() else { return nil }
        exercise.completionDelegate = self
        return exercise
    }
    
    /// Create exercises on 10 words, this will create the factories, which hold all the information to create the exercise view controllers
    func createExercises() {
        var rounds = Array(repeating: [ExerciseFactory](), count: 3)
        let exerciseWords = dictionaryService.wordsForExercise()

        for exerciseWord in exerciseWords {
            let factories: [ExerciseFactory] = {
                switch exerciseWord.userLevel {
                    case .new:
                    return createExercisesForNew(exerciseWord: exerciseWord, sentenceService: sentenceService, wordService: wordService, speechSynth: speechSynth)
    
                    case .unfamiliar:
                    return createExercisesForNew(exerciseWord: exerciseWord, sentenceService: sentenceService, wordService: wordService, speechSynth: speechSynth)
    
                    case .familiar:
                    return createExercisesForNew(exerciseWord: exerciseWord, sentenceService: sentenceService, wordService: wordService, speechSynth: speechSynth)
    
                    case .fluent:
                    return createExercisesForNew(exerciseWord: exerciseWord, sentenceService: sentenceService, wordService: wordService, speechSynth: speechSynth)
                }
            }()

            for i in 0..<factories.count {
            if (i > 2) { break } // the rounds array only has 3 indices
               rounds[i].append(factories[i]) 
            }
        }
        
        exercises = rounds[0].shuffled() + rounds[1].shuffled() + rounds[2].shuffled()
    }

    private func createExercisesForNew(exerciseWord: ExerciseWord,
                                              sentenceService: SentenceService,
                                              wordService: WordService,
                                              speechSynth: SpeechSynth) -> [ExerciseFactory] {
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
                    ),
                    speechSynth: speechSynth
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
            onShowSummary?()
        } else {
            onLoadNextExercise?()
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
