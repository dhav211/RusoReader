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
    
    func testFetchSetencesWithMaxLimit() throws {
        let sentences = sentenceRepo.findSentences(by: 143, sentenceLimit: Int.max)
        
        XCTAssert(sentences.count > 0)
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
        
        XCTAssert(sut?.location == 0)
        XCTAssert(sut?.length == 8)
    }
    
    func testGetLocationOfAdjectiveInMiddleOfSentence() throws {
        guard let word = wordRepo.findMatches(by: [309]).first else {
            XCTFail("Failed to find the word настоящий")
            return
        }
        
        let sut = sentenceService.getRange(of: word, in: "Я не настоя'щая ры'ба; я всего лишь плю'шевая игру'шка.")
        XCTAssert(sut?.location == 5)
        XCTAssert(sut?.length == 10)
    }
    
    func testGetLocationOfLastWordInSentence() throws {
        guard let word = wordRepo.findMatches(by: [234]).first else {
            XCTFail("Failed to find the word сегодня")
            return
        }
        
        let sut = sentenceService.getRange(of: word, in: "18 ию'ня, и э'то день рожде'ния Сего'дня!")
        XCTAssert(sut?.location == 32)
        XCTAssert(sut?.length == 8)
    }
    
    func testGetLocationOfWordNotInSentence() throws {
        guard let word = wordRepo.findMatches(by: [234]).first else {
            XCTFail("Failed to find the word сегодня")
            return
        }
        
        let sut = sentenceService.getRangeWithStress(of: word, in: sentenceService.addStress(sentence: "18 ию'ня э'то день рожде'ния!"))
        
        XCTAssert(sut == nil)
    }
    
    func testGetLocationOfVerbInInfintiveForm() throws {
        guard let word = wordRepo.findMatches(by: [53]).first else {
            XCTFail("Failed to find the word говорить")
            return
        }
        
        let sut = sentenceService.getRangeWithStress(of: word, in: sentenceService.addStress(sentence: "Я не могу говори'ть с ним."))
        XCTAssert(sut?.location == 10)
        XCTAssert(sut?.length == 9)
    }
    
    func testGetLocationOfVerbБудь() throws {
        guard let word = wordRepo.findMatches(by: [9]).first else {
            XCTFail("Failed to find the word быть")
            return
        }
        
        let sut = sentenceService.getRangeWithStress(of: word, in: sentenceService.addStress(sentence: "Бу'дь моим Валенитом."))
        XCTAssert(sut?.location == 0)
        XCTAssert(sut?.length == 5)
    }
    
    func testGetSentencesWithLimitOf150Chars() throws {
        let sentences = sentenceRepo.findSentencesWithLengthLimit(by: 715, with: 150)
        
        for sentence in sentences {
            if sentence.text.count > 150 {
                XCTFail("Sentence has more than 150 characters")
            }
        }
    }
    
    func testGetSentencesWithLimitHigherThan150Chars() throws {
        let sentences = sentenceRepo.findSentencesWithLengthLimit(by: 715, with: 250)
        var numberOfSentencesGreaterThan150 = 0
        
        for sentence in sentences {
            if sentence.text.count > 150 {
                numberOfSentencesGreaterThan150 += 1
            }
        }
        
        XCTAssert(numberOfSentencesGreaterThan150 > 0)
    }
}

