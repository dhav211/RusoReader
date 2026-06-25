import XCTest
@testable import rusoreader

final class SentenceTests: XCTestCase {
    private var databaseManager: DatabaseManager!
    private var sentenceRepo: SentenceRepository!
    
    override func setUpWithError() throws {
        databaseManager = DatabaseManager()
        sentenceRepo = SentenceRepository(databaseManager: databaseManager)
    }

    override func tearDownWithError() throws {
        databaseManager = nil
        sentenceRepo = nil
    }

    func testFetch25SentencesByWordID() throws {
        let sentences = sentenceRepo.findSentences(by: 143)
        XCTAssert(sentences.count == 25)
    }
    
    func testNoSentencesWithNegativeNumber() throws {
        let sentences = sentenceRepo.findSentences(by: -54)
        XCTAssert(sentences.isEmpty)
    }
    
    func testNoSentencesWithTooHighNumber() throws {
        let sentences = sentenceRepo.findSentences(by: Int.max)
        XCTAssert(sentences.isEmpty)
    }
    
    func testSentencesWithLessThan25() throws {
        let sentences = sentenceRepo.findSentences(by: 911125)
        XCTAssert(sentences.count < 25)
    }
}

