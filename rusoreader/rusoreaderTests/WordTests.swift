import XCTest
@testable import rusoreader

final class WordTests: XCTestCase {
    private var wordService: WordService!
    private var databaseManager: DatabaseManager!
    private var wordRepo: WordRepository!
    private var sentenceRepo: SentenceRepository!
    private var dictionaryRepo: DictionaryRepository!
    
    override func setUpWithError() throws {
        databaseManager = DatabaseManager()
        wordRepo = WordRepository(databaseManager: databaseManager)
        sentenceRepo = SentenceRepository(databaseManager: databaseManager)
        dictionaryRepo = DictionaryRepository(databaseManager: databaseManager)
        wordService = WordService(wordRepo: wordRepo, sentenceRepo: sentenceRepo, dictionaryRepo: dictionaryRepo)
    }

    override func tearDownWithError() throws {
        databaseManager = nil
        wordRepo = nil
        sentenceRepo = nil
        dictionaryRepo = nil
        wordService = nil
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
    
    func testFindByIDs() throws {
        let expectedWords = ["весь", "человек", "видеть", "женщина"]
        let words = wordService.findMatches(from: [12, 34, 94, 169])
        XCTAssert(words.count == 4)
        
        for expectedWord in expectedWords {
            if !words.contains(where: {$0.bare == expectedWord}) {
                XCTFail("The returned words from the database didn't contain the expected word \(expectedWord)")
            }
        }
    }
    
    func testRemoveCommaFromWord() throws {
        let sut = wordService.removePunctuation(from: "дьявола,")
        XCTAssert(sut == "дьявола")
    }

    func testRemoveCommaFromWordWithStress() throws {
        let sut = wordService.removePunctuation(from: "дья'вола,")
        XCTAssert(sut == "дья'вола")
    }
    
    func testRemoveCommaFromWordWithBuiltinStress() throws {
        let sut = wordService.removePunctuation(from: "дья́вола,")
        XCTAssert(sut == "дья́вола")
    }
    
    func testХотетьHas18WordForms() throws {
        let word = wordRepo.findMatches(by: [90]).first!
        XCTAssert(word.forms.count == 18)
    }
    
    func testGetStemForЖенщина() throws {
        let word = wordRepo.findMatches(by: [169]).first!
        let stem = wordService.getWordStem(of: word)
        let expected = "женщин"
        
        XCTAssert(stem == expected)
    }
    
    func testGetStemForВстретиться() throws {
        let word = wordRepo.findMatches(by: [1169]).first!
        let stem = wordService.getWordStem(of: word)
        let expected = "встре"
        
        XCTAssert(stem == expected)
    }

    func testWordWithAccentMarkSize() throws {
        XCTAssert("сказа́".count == "сказа".count)
    }

    func test3VowelWordForMultipleVowels() throws {
        let sut = wordService.findMatches(from: [28]).first!
        XCTAssert(wordService.hasMultipleVowels(sut) == true)
    }

    func test1VowelWordForMultipleVowels() throws {
        let sut = wordService.findMatches(from: [12]).first!
        XCTAssert(wordService.hasMultipleVowels(sut) == false)
    }

    func testEmptyStringForMultipleVowels() throws {
        let sut = Word(id: 0, bare: "", accented: "", type: .other, level: "A1", ranking: 0, noun: nil, verb: nil, forms: [], translations: [])
        XCTAssert(wordService.hasMultipleVowels(sut) == false)
    }

    func testNoVowelAcronymForMultipleVowels() throws {
        let sut = Word(id: 0, bare: "ссср", accented: "ссср", type: .other, level: "A1", ranking: 0, noun: nil, verb: nil, forms: [], translations: [])
        XCTAssert(wordService.hasMultipleVowels(sut) == false)
    }

    func testSeperateWordFormByComma() throws {
        let sut = wordService.getRandomCommaSeperatedWordForm("test,testy")
        XCTAssert(!sut.contains(","))
        XCTAssert(sut == "test" || sut == "testy")
    }

    func testSeperateWordFormWithoutComma() throws {
        let sut = wordService.getRandomCommaSeperatedWordForm("testtesty")
        XCTAssert(sut == "testtesty")
    }
}

