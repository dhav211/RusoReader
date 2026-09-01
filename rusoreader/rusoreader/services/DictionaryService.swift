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
    
    func update(word: Word, scoreChangeAmount: Double, newDueDate: Date) {
        dictionaryRepo.update(word: word, scoreChangeAmount: scoreChangeAmount, newDueDate: newDueDate)
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
