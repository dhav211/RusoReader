import XCTest
@testable import rusoreader

final class WordTests: XCTestCase {
    private var wordService: WordService!
    private var databaseManager: DatabaseManager!
    private var wordRepo: WordRepository!
    private var sentenceRepo: SentenceRepository!
    
    override func setUpWithError() throws {
        databaseManager = DatabaseManager()
        wordRepo = WordRepository(databaseManager: databaseManager)
        sentenceRepo = SentenceRepository(databaseManager: databaseManager)
        wordService = WordService(wordRepo: wordRepo, sentenceRepo: sentenceRepo)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFindAdjectiveBase() throws {
        XCTAssert(wordService.findAdjectiveBase(for: "Уникальный") == "Уникальн")
        XCTAssert(wordService.findAdjectiveBase(for: "холодному") == "холодн")
        
    }

    func testIsVowel() throws {
        XCTAssert(wordService.isVowel(letter: "а") == true)
        XCTAssert(wordService.isVowel(letter: "А") == true)
        XCTAssert(wordService.isVowel(letter: "н") == false)
        XCTAssert(wordService.isVowel(letter: "е") == true)
        XCTAssert(wordService.isVowel(letter: "a") == false) // That's an latin a
    }
    
    func testReplaceVowelWithStressed() throws {
        XCTAssert(wordService.addStress(to: "сказа'в") == "сказа́в")
        XCTAssert(wordService.addStress(to: "ск'азав") == "сказав")
        XCTAssert(wordService.addStress(to: "сказав") == "сказав")
        XCTAssert(wordService.addStress(to: "сказа'") == "сказа́")
        XCTAssert(wordService.addStress(to: "ска'за'в") == "сказав")
        XCTAssert(wordService.addStress(to: "до'мик") == "до́мик")
    }
}

