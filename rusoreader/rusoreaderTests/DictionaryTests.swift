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
        databaseManager = DatabaseManager()
        dictionaryRepo = DictionaryRepository(databaseManager: databaseManager)
        wordRepo = WordRepository(databaseManager: databaseManager)
        sentenceRepo = SentenceRepository(databaseManager: databaseManager)
        
        wordService = WordService(wordRepo: wordRepo, sentenceRepo: sentenceRepo, dictionaryRepo: dictionaryRepo)
        dictionaryService = DictionaryService(dictionaryRepo: dictionaryRepo, wordService: wordService)
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
        XCTAssert(dictionaryRepo.count == 2)
    }
    
    func testWordAlreadyInDictionary() throws {
        dictionaryRepo.addWord(by: 1)
        dictionaryRepo.addWord(by: 1)
        XCTAssert(dictionaryRepo.count == 1)
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
        XCTAssert(dictionaryRepo.count == 0)
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
}
