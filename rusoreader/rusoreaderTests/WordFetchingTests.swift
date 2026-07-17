import XCTest
@testable import rusoreader

final class WordFetchingTests: XCTestCase {
    var wordRepo: WordRepository!
    
    override func setUpWithError() throws {
        let databaseManager = DatabaseManager()
        wordRepo = WordRepository(databaseManager: databaseManager)
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
    
    func testFindAllFormsOfчеловек() throws {
        let sut = wordRepo.findUniqueWordForms(for: 34)
        let expected = ["людей","люди","людьми","людям","людях","человек","человека","человекам","человеками","человеках","человеке","человеки","человеков","человеком","человеку"]
        
        for word in sut {
            if !expected.contains(word) {
                XCTFail("\(word) not found in expected words")
            }
        }
    }
    
    func testFindAllFormsOfчеловекWithStress() throws {
        let sut = wordRepo.findUniqueStressedWordForms(accentedBaseForm: "челове'к", wordId: 34)
        let expected = [
            "челове'к",
            "челове'ка",
            "челове'ку",
            "челове'ком",
            "челове'ке",
            "лю'ди",
            "челове'ки",
            "люде'й",
            "челове'ков",
            "лю'дям",
            "челове'кам",
            "людьми'",
            "челове'ками",
            "лю'дях",
            "челове'ках"
        ]
        
        for word in sut {
            if !expected.contains(word) {
                XCTFail("\(word) not found in expected words")
            }
        }
    }
    
    func testFindAllFormsOfNoWord() throws {
        let sut = wordRepo.findUniqueWordForms(for: Int.max)
        
        XCTAssert(sut.count == 0)
    }
}
