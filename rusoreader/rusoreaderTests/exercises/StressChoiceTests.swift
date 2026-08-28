import XCTest
@testable import rusoreader

final class StressChoiceTests: XCTestCase {
    private var databaseManager: DatabaseManager!
    private var wordRepo: WordRepository!
    private var wordService: WordService!
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
        wordRepo = nil
        sentenceRepo = nil
        dictionaryRepo = nil
        databaseManager = nil
        wordService = nil
    }
    
    func test3Vowel() throws {
        let word = wordRepo.findMatches(by: [34]).first!
        
        let sut = StressChoiceExerciseFactory(word: word, wordService: wordService)
        let expected = ["че'ловек", "чело'век"]

        XCTAssert(sut.incorrectStressedWordChoices.sorted() == expected.sorted())
    }

    func testWordWithЁ() throws {
        let word = wordRepo.findMatches(by: [479]).first!
        
        let sut = StressChoiceExerciseFactory(word: word, wordService: wordService)
        let expected = ["зе'лёный", "зелёны'й"]

        XCTAssert(sut.incorrectStressedWordChoices.sorted() == expected.sorted())
    }
    
    func testWordWithVowelAtEnd() throws {
        let word = wordRepo.findMatches(by: [153]).first!
        
        let sut = StressChoiceExerciseFactory(word: word, wordService: wordService)
        let expected = ["зе'мля"]

        XCTAssert(sut.incorrectStressedWordChoices.sorted() == expected.sorted())
    }

    func testWordWithoutVowels() throws {
        let word = Word(id: 0, bare: "ссср", accented: "ссср", type: .noun, level: "A1", ranking: 0, noun: nil, verb: nil, forms: [WordForm](), translations: [String]())
        
        let sut = StressChoiceExerciseFactory(word: word, wordService: wordService)
        let expected = [String]()

        XCTAssert(sut.incorrectStressedWordChoices.sorted() == expected.sorted())
    }
}
