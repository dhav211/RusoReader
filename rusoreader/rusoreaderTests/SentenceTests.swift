import XCTest
@testable import rusoreader

final class SentenceTests: XCTestCase {
    private var databaseManager: DatabaseManager!
    private var sentenceRepo: SentenceRepository!
    private var dictionaryRepo: DictionaryRepository!
    private var wordRepo: WordRepository!
    private var wordService: WordService!
    private var sentenceService: SentenceService!
    
    override func setUpWithError() throws {
        databaseManager = DatabaseManager()
        sentenceRepo = SentenceRepository(databaseManager: databaseManager)
        wordRepo = WordRepository(databaseManager: databaseManager)
        dictionaryRepo = DictionaryRepository(databaseManager: databaseManager)
        wordService = WordService(wordRepo: wordRepo, sentenceRepo: sentenceRepo, dictionaryRepo: dictionaryRepo)
        sentenceService = SentenceService(sentenceRepo: sentenceRepo, wordRepo: wordRepo, wordService: wordService)
    }

    override func tearDownWithError() throws {
        databaseManager = nil
        sentenceRepo = nil
        wordRepo = nil
        dictionaryRepo = nil
        sentenceRepo = nil
        wordService = nil
        sentenceService = nil
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
    
    func testGetLocationOfFirstWordInSentence() throws {
        guard let word = wordRepo.findMatches(by: [234]).first else {
            XCTFail("Failed to find the word сегодня")
            return
        }
        
        let sut = sentenceService.getRange(of: word, in: "Сего'дня 18 ию'ня, и э'то день рожде'ния Мюриэл!")
    }
    
    func testGetLocationOfAdjectiveInMiddleOfSentence() throws {
        guard let word = wordRepo.findMatches(by: [309]).first else {
            XCTFail("Failed to find the word сегодня")
            return
        }
        
        let sut = sentenceService.getRange(of: word, in: "Я не настоя'щая ры'ба; я всего лишь плю'шевая игру'шка.")
    }
    
    func testGetLocationOfLastWordInSentence() throws {
        guard let word = wordRepo.findMatches(by: [234]).first else {
            XCTFail("Failed to find the word сегодня")
            return
        }
        
        let sut = sentenceService.getRange(of: word, in: "18 ию'ня, и э'то день рожде'ния Сего'дня!")
    }
    
    func testGetLocationOfLastWordInSentenceWithStress() throws {
        guard let word = wordRepo.findMatches(by: [234]).first else {
            XCTFail("Failed to find the word сегодня")
            return
        }
        
        let sut = sentenceService.getRangeWithStress(of: word, in: sentenceService.addStress(sentence: "18 ию'ня, и э'то день рожде'ния Сего'дня!"))
    }
}

