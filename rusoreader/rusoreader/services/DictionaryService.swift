import Foundation

class DictionaryService {
    private let dictionaryRepo: DictionaryRepository
    private let wordService: WordService
    
    init(dictionaryRepo: DictionaryRepository, wordService: WordService) {
        self.dictionaryRepo = dictionaryRepo
        self.wordService = wordService
    }
    
    /// The total number of entries added to the dictionary
    var count: Int { dictionaryRepo.count }
    
    func getAllWords() -> [Word] {
        let wordIds = dictionaryRepo.getAll().map { entry in
            return entry.wordId
        }
        
        return wordService.findMatches(from: wordIds)
    }

    func wordsForExercise() -> [ExerciseWord] {
        var chosenWords = Set<ExerciseWord>()
        
        let allOverDueWords = dictionaryRepo.getAllDueWords()
        let randomOverDueWords = Array(allOverDueWords.shuffled()[0..<min(7,allOverDueWords.count)])
        // grab some extra words from the user's dictionary if there aren't enough overdue words
        let weakestDictionaryWords = randomOverDueWords.count < 5
            ? {
                // this array of ids will be used to exclude any of the fetched dictionary entries
                let overDueWordIds = randomOverDueWords.map { return $0.wordId }
                // we just want to make the up remainder of words to return
                let requiredNumberOfWords = 5 - randomOverDueWords.count
                // Grab any and every word the user has added to thier dictionary then sort them by weakest words to strongest
                let allDictionaryWords = dictionaryRepo.getAll()
                    .filter({ !overDueWordIds.contains($0.wordId) })
                    .sorted(by: { $0.score < $1.score })
                return Array(allDictionaryWords[0..<min(requiredNumberOfWords, allDictionaryWords.count)])
            }()
            : [DictionaryEntry]()

        // The exercise words need an associated word to generate sentences, so fetch the words with ids from the dictionary entries
        var words = wordService.findMatches(from: Array(allOverDueWords + weakestDictionaryWords).map { return $0.wordId })

        // Here we begin constructing the exercise words by finding word id matches with the words and the dictionary entries
        for entry in Array(randomOverDueWords + weakestDictionaryWords) {
            for i in 0..<words.count {
                if entry.wordId == words[i].id {
                    let word = words.remove(at: i) // Remove the word so the next loop around will be slightly faster
                    chosenWords.insert(ExerciseWord(word: word, timesAppeared: entry.timesAppeared, score: Double(entry.score)))
                    break;
                }
            }
        }

        // If we can't find a minimum of 5 words in the dictionary then we will get the remainder from the words db and just add them to the dictionary
        if chosenWords.count < 5 {
            // We will grab 10 random ids from 100 to 1000, these will be some commonly known words for the user
            let randomIds = Array((100..<1000).shuffled().prefix(10))
            // get the ids of the already chosen words so we can be sure we don't double add them
            let chosenWordIds = chosenWords.map { $0.id }
            let requiredNumberOfWords = 5 - chosenWords.count
            // Grab the words from the word db, but only the bare needed amount
            let words = wordService.findMatches(from: Array(randomIds.filter({ !chosenWordIds.contains($0) })[0..<requiredNumberOfWords]))

            // We will just add them to the dictionary so we won't have to go through this process again
            dictionaryRepo.addWords(by: words.map { return $0.id })
            let addedExerciseWords = words.map { return ExerciseWord(word: $0, timesAppeared: 0, score: 3.0)}
            return addedExerciseWords + chosenWords
        }
        
        return Array(chosenWords)
    }
    
    func update(word: Word, scoreChangeAmount: Double, newDueDate: Date) {
        dictionaryRepo.update(word: word, scoreChangeAmount: scoreChangeAmount, newDueDate: newDueDate)
    }

    func updateScore(word: Word, scoreChangeAmount: Double) {
        dictionaryRepo.updateScore(for: word.id, by: scoreChangeAmount)
    }

    func increaseTimesAppeared(word: Word) {
        dictionaryRepo.increaseTimesAppeared(for: word.id)
    }

    func daysUntilNextDueDate(wordId: Int, exerciseScoreAmount: Double) -> Int {
        guard let dictionaryEntry = dictionaryRepo.find(by: wordId) else { return 0 }
        let previousScore = Double(dictionaryEntry.score)
        
        // We will apply some dampening so the timesAppeared is a factor but won't swing the results too crazy
        let dampeningFactor = 0.1
        let dampening = 1.0 / (1.0 + Double(dictionaryEntry.timesAppeared) * dampeningFactor)
        let dueDateScore = abs(previousScore + exerciseScoreAmount * dampening)

        // Maturity check off first_seen, compares how long the word has been in the dictionary with how many times the
        // user has been tested on it
        let matureAgeDays = 30 // number of days that we will consider a entry mature
        let matureAppearances = 5 // however it must also been seen in exercises this amount of times
        let daysSinceFirstSeen = Calendar.current.dateComponents(
            [.day], from: dictionaryEntry.firstSeen, to: Date.now
        ).day ?? 0
        let isMature = daysSinceFirstSeen >= matureAgeDays && dictionaryEntry.timesAppeared >= matureAppearances

        switch dueDateScore {
        case 4.0...:              // not good
            return 1
        case 1.5..<4.0:              // normal
            return 3
        case 0.3..<1.5:              // good
            return 7
        default:                     // score is good (< 0.3)
            return isMature ? 30 : 7
        }
    }
}
