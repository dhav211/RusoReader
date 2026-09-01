import XCTest
@testable import rusoreader
import GRDB

final class DictionaryTests: XCTestCase {
    var databaseManager: DatabaseManager!
    var dictionaryRepo: DictionaryRepository!
    var wordRepo: WordRepository!
    var sentenceRepo: SentenceRepository!
    var wordService: WordService!
    var dictionaryService: DictionaryService!
    
    override func setUpWithError() throws {
        databaseManager = DatabaseManager(createFresh: false)
        dictionaryRepo = DictionaryRepository(databaseManager: databaseManager)
        wordRepo = WordRepository(databaseManager: databaseManager)
        sentenceRepo = SentenceRepository(databaseManager: databaseManager)
        
        wordService = WordService(wordRepo: wordRepo, sentenceRepo: sentenceRepo, dictionaryRepo: dictionaryRepo)
        dictionaryService = DictionaryService(dictionaryRepo: dictionaryRepo, wordService: wordService)

        if dictionaryRepo.count > 0 {
            dictionaryRepo.clear()
        }
    }
    
    override func tearDownWithError() throws {
        dictionaryRepo.clear()

        databaseManager = nil
        dictionaryRepo = nil
        wordRepo = nil
        sentenceRepo = nil
        wordService = nil
        dictionaryService = nil
    }
    
    func testAddWordToDictionary() throws {
        dictionaryRepo.addWord(by: 1)
        dictionaryRepo.addWord(by: 4)
        let count = dictionaryRepo.count
        XCTAssert(count == 2)
    }
    
    func testWordAlreadyInDictionary() throws {
        dictionaryRepo.addWord(by: 1)
        dictionaryRepo.addWord(by: 1)
        let count = dictionaryRepo.count
        XCTAssert(count == 1)
    }
    
    func testWordScoreIncreasesOnReAdd() throws {
        dictionaryRepo.addWord(by: 1)
        let entry = dictionaryRepo.find(by: 1)
        XCTAssert(entry?.score == 3)
        dictionaryRepo.addWord(by: 1)
        let entryAfterFirstUpdate = dictionaryRepo.find(by: 1)
        XCTAssert(entryAfterFirstUpdate?.score == 3)
        dictionaryRepo.addWord(by: 1)
        dictionaryRepo.addWord(by: 1)
        let entryAfterFinalUpdate = dictionaryRepo.find(by: 1)
        XCTAssert(entryAfterFinalUpdate?.score == 4)
    }
    
    func testAddNegativeOrZeroWordId() throws {
        dictionaryRepo.addWord(by: 0)
        dictionaryRepo.addWord(by: -4)
        let count = dictionaryRepo.count
        XCTAssert(count == 0)
    }
    
    func testTimesClicked() throws {
        dictionaryRepo.addWord(by: 1)
        dictionaryRepo.addWord(by: 2)
        dictionaryRepo.addWord(by: 1)

        let entry = dictionaryRepo.find(by: 1)
        
        XCTAssert(entry?.timesClicked == 2)
    }
    
    func testGetAll() throws {
        let words = wordService.findMatches(from: [12, 34, 94, 169])
        
        for word in words {
            wordService.addWordToUserDictionary(word: word)
        }
        
        let wordsFromDictionary = dictionaryService.getAllWords()
        
        XCTAssert(wordsFromDictionary.count == 4)
        
        for word in wordsFromDictionary {
            if !words.contains(where: { $0.bare == word.bare }) {
                XCTFail("Dictionary doesn't contain the word \(word.bare)")
            }
        }
        
        dictionaryRepo.clear()
    }
    
    func testIncreaseWordsScore() throws {
        dictionaryRepo.addWord(by: 34)
        try dictionaryRepo.updateScore(for: 34, by: 0.5)
        try dictionaryRepo.updateScore(for: 34, by: 1.0)
        
        guard let entry = dictionaryRepo.find(by: 34) else {
            XCTFail("Couldn't find the dictionary entry by ID 34")
            return
        }
        
        XCTAssert(entry.score == 4.5)
    }
    
    func testDecreaseScoreUntilNegative() throws {
        dictionaryRepo.addWord(by: 34)
        try dictionaryRepo.updateScore(for: 34, by: -2.5)
        try dictionaryRepo.updateScore(for: 34, by: -1.0)
        
        guard let entry = dictionaryRepo.find(by: 34) else {
            XCTFail("Couldn't find the dictionary entry by ID 34")
            return
        }

        XCTAssert(entry.score == 0.0)
    }
    
    func testUpdateNonExisitingEntry() throws {
        try dictionaryRepo.updateScore(for: 34, by: 0.5)
        try dictionaryRepo.updateScore(for: 34, by: 1.0)
        
        guard dictionaryRepo.find(by: 34) != nil else {
            return
        }
        
        XCTFail()
    }

    func testGetAllNeverSeenBeforeWordsWhenLessThanFive() throws {
        dictionaryRepo.addWord(by: 77)
        dictionaryRepo.addWord(by: 12)
        dictionaryRepo.addWord(by: 99)

        let neverBeforeSeenWords = dictionaryRepo.getNeverBeforeSeenWords()
        XCTAssert(neverBeforeSeenWords.count == 3)
    }

    func testGetAllNeverSeenBeforeWordsWhenGreaterThanFive() throws {
        dictionaryRepo.addWord(by: 77)
        dictionaryRepo.addWord(by: 12)
        dictionaryRepo.addWord(by: 99)
        dictionaryRepo.addWord(by: 177)
        dictionaryRepo.addWord(by: 112)
        dictionaryRepo.addWord(by: 199)

        let neverBeforeSeenWords = dictionaryRepo.getNeverBeforeSeenWords()
        XCTAssert(neverBeforeSeenWords.count == 5)
    }

    func testGetAllNeverSeenBeforeWordsWithLimitOfThree() throws {
        dictionaryRepo.addWord(by: 77)
        dictionaryRepo.addWord(by: 12)
        dictionaryRepo.addWord(by: 99)
        dictionaryRepo.addWord(by: 177)
        dictionaryRepo.addWord(by: 112)
        dictionaryRepo.addWord(by: 199)

        let neverBeforeSeenWords = dictionaryRepo.getNeverBeforeSeenWords(limit: 3)
        XCTAssert(neverBeforeSeenWords.count == 3)
    }

    func testGetAllNeverSeenBeforeWordsWhenNoWordsAdded() throws {
        let neverBeforeSeenWords = dictionaryRepo.getNeverBeforeSeenWords()
        XCTAssert(neverBeforeSeenWords.count == 0)
    }

    func testGetAllOverDueWords() throws {
        dictionaryRepo.addWord(by: 77, dueDate: Date.now - TimeInterval(60 * 60 * 2))
        dictionaryRepo.addWord(by: 12, dueDate: Date.now - TimeInterval(60 * 60 * 2))
        dictionaryRepo.addWord(by: 99, dueDate: Date.now - TimeInterval(60 * 60 * 2))
        dictionaryRepo.addWord(by: 177)
        dictionaryRepo.addWord(by: 112, dueDate: Date.now - TimeInterval(60 * 60 * 2))
        dictionaryRepo.addWord(by: 199)

        let overdueWords = dictionaryRepo.getAllDueWords()
        XCTAssert(overdueWords.count == 4)
    }

    func testGetNoOverDueWordsNoneAreOverDue() throws {
        dictionaryRepo.addWord(by: 77)
        dictionaryRepo.addWord(by: 12)
        dictionaryRepo.addWord(by: 99)
        dictionaryRepo.addWord(by: 177)
        dictionaryRepo.addWord(by: 112)
        dictionaryRepo.addWord(by: 199)

        let overdueWords = dictionaryRepo.getAllDueWords()
        XCTAssert(overdueWords.count == 0)
    }

    func testGetDueDateNextWeekCorrectAnswerForStrongWord() throws {
        dictionaryRepo.addWord(
            by: 77, 
            score: 2.0, 
            timesClicked: 1, 
            timesAppeared: 3, 
            firstSeen: Date.now - TimeInterval(60 * 60 * 15), 
            lastSeen: Date.now - TimeInterval(60 * 60 * 3), 
            dueDate: Date.now
        )

        let exerciseScore = -0.75
        let daysToNextDueDate = dictionaryService.daysUntilNextDueDate(wordId: 77, exerciseScoreAmount: exerciseScore)
        XCTAssert(daysToNextDueDate == 7)
    }

    func testGetDueDate1DayCorrectAnswerForWeakWord() throws {
        dictionaryRepo.addWord(
            by: 77, 
            score: 8.0, 
            timesClicked: 6, 
            timesAppeared: 13, 
            firstSeen: Date.now - TimeInterval(60 * 60 * 15), 
            lastSeen: Date.now - TimeInterval(60 * 60 * 3), 
            dueDate: Date.now
        )

        let exerciseScore = -1.0
        let daysToNextDueDate = dictionaryService.daysUntilNextDueDate(wordId: 77, exerciseScoreAmount: exerciseScore)
        XCTAssert(daysToNextDueDate == 1)
    }

    func testGetDueDate3DayCorrectAnswerForNewWord() throws {
        dictionaryRepo.addWord(
            by: 77, 
            score: 3.0, 
            timesClicked: 1, 
            timesAppeared: 1, 
            firstSeen: Date.now - TimeInterval(60 * 60 * 15), 
            lastSeen: Date.now - TimeInterval(60 * 60 * 3), 
            dueDate: Date.now
        )

        let exerciseScore = -0.5
        let daysToNextDueDate = dictionaryService.daysUntilNextDueDate(wordId: 77, exerciseScoreAmount: exerciseScore)
        XCTAssert(daysToNextDueDate == 3)
    }

    func testGetWeekDueDateForAllZeroValues() throws {
        dictionaryRepo.addWord(
            by: 77, 
            score: 0.0, 
            timesClicked: 0, 
            timesAppeared: 0, 
            firstSeen: Date.now - TimeInterval(60 * 60 * 15), 
            lastSeen: Date.now - TimeInterval(60 * 60 * 3), 
            dueDate: Date.now
        )

        let exerciseScore = 0.0
        let daysToNextDueDate = dictionaryService.daysUntilNextDueDate(wordId: 77, exerciseScoreAmount: exerciseScore)
        XCTAssert(daysToNextDueDate == 7)
    }
    
    func testDueDateInFutureHasNoEffectOnNewDueDate() throws {
        dictionaryRepo.addWord(
            by: 77,
            score: 3.0,
            timesClicked: 1,
            timesAppeared: 1,
            firstSeen: Date.now - TimeInterval(60 * 60 * 15),
            lastSeen: Date.now - TimeInterval(60 * 60 * 3),
            dueDate: Date.now + TimeInterval(60 * 60 * 30)
        )

        let exerciseScore = -0.5
        let daysToNextDueDate = dictionaryService.daysUntilNextDueDate(wordId: 77, exerciseScoreAmount: exerciseScore)
        XCTAssert(daysToNextDueDate == 3)
    }
    
    func testFirstSeenIsInFuture() throws {
        dictionaryRepo.addWord(
            by: 77,
            score: 3.0,
            timesClicked: 1,
            timesAppeared: 1,
            firstSeen: Date.now + TimeInterval(60 * 60 * 15),
            lastSeen: Date.now - TimeInterval(60 * 60 * 3),
            dueDate: Date.now
        )

        let exerciseScore = -0.5
        let daysToNextDueDate = dictionaryService.daysUntilNextDueDate(wordId: 77, exerciseScoreAmount: exerciseScore)
        XCTAssert(daysToNextDueDate == 3)
    }
    
    func testFirstSeenIsInFutureAndMatureStatus() throws {
        dictionaryRepo.addWord(
            by: 77,
            score: 3.0,
            timesClicked: 1,
            timesAppeared: 1,
            firstSeen: Date.now + TimeInterval(60 * 60 * 15),
            lastSeen: Date.now - TimeInterval(60 * 60 * 3),
            dueDate: Date.now
        )

        let exerciseScore = -2.9
        let daysToNextDueDate = dictionaryService.daysUntilNextDueDate(wordId: 77, exerciseScoreAmount: exerciseScore)
        XCTAssert(daysToNextDueDate == 7)
    }
}
