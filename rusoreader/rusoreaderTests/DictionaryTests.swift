import XCTest
@testable import rusoreader
import GRDB

final class DictionaryTests: XCTestCase {
    var databaseManager: DatabaseManager!
    var dictionaryRepo: DictionaryRepository!
    
    override func setUpWithError() throws {
        databaseManager = DatabaseManager()
        dictionaryRepo = DictionaryRepository(databaseManager: databaseManager)
    }
    
    override func tearDownWithError() throws {
        dictionaryRepo.clear()
        databaseManager = nil
        dictionaryRepo = nil
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
}
