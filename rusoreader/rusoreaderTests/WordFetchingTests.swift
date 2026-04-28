import XCTest
@testable import rusoreader

final class WordFetchingTests: XCTestCase {
    var wordRepo: WordRepository!
    
    override func setUpWithError() throws {
        let databaseManager = DatabaseManager()
        wordRepo = WordRepository(queue: databaseManager.queue)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFindNounWithSingleMatch() throws {
        let ids = wordRepo.findWordIDs(by: "год")
        let matches = wordRepo.findMatches(by: ids)
            
        guard let result = matches.first else { return XCTFail() }
        guard let noun = result.noun else { return XCTFail() }
        
        XCTAssert(result.bare == "год")
        XCTAssert(!result.forms.isEmpty)
        XCTAssert(noun.gender == Noun.Gender.male)
    }
    
    func testFindWordsWithMultipleIDs() throws {
        let ids: [Int64] = [140, 143]
        let matches = wordRepo.findMatches(by: ids)
        XCTAssert(matches.count == 2)
    }
    
    func testGetWordIDsFromWordBare() throws {
        let matches = wordRepo.findWordIDs(by: "замок")
        
        for match in matches {
            XCTAssert(match == 58499 || match == 58500)
        }
    }
    
    func testGetWordIdForWordMissingЁ() throws {
        let matches = wordRepo.findWordIDs(by: "семерка")
        
        XCTAssert(matches.count == 1)
    }
    
    func testGetWordIdFromVerbBase() throws {
        let matches = wordRepo.findWordIDs(by: "вкалывать")
        
        XCTAssert(matches.count == 1)
    }
}
