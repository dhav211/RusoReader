//сказа'в    сказав
//сказавши    сказавши

import XCTest
@testable import rusoreader

final class TypeSpeechTests: XCTestCase {
    private var databaseManager: DatabaseManager!
    private var wordRepo: WordRepository!
    private var wordService: WordService!
    private var sentenceRepo: SentenceRepository!
    private var dictionaryRepo: DictionaryRepository!
    private var speechSynth: SpeechSynth!
    
    
    override func setUpWithError() throws {
        databaseManager = DatabaseManager()
        wordRepo = WordRepository(databaseManager: databaseManager)
        sentenceRepo = SentenceRepository(databaseManager: databaseManager)
        dictionaryRepo = DictionaryRepository(databaseManager: databaseManager)
        wordService = WordService(wordRepo: wordRepo, sentenceRepo: sentenceRepo, dictionaryRepo: dictionaryRepo)
        speechSynth = SpeechSynth()
    }
    
    override func tearDownWithError() throws {
        wordRepo = nil
        sentenceRepo = nil
        dictionaryRepo = nil
        databaseManager = nil
        wordService = nil
        speechSynth = nil
    }
    
    func testGetFirstAccentedWordForm() throws {
        let sut = TypeSpeechExerciseViewModel(word: Word(), wordForm: WordForm(bare: "сказав,сказавши", accented: "сказа'в,сказавши", form: .gerundPast), wordService: wordService)
        XCTAssert(sut.spokenText == "сказа́в")
    }
    
    func testGetSingleAccentedWordForm() throws {
        let sut = TypeSpeechExerciseViewModel(word: Word(), wordForm: WordForm(bare: "инженере", accented: "инжене'ре", form: .nounSingularPrepositional), wordService: wordService)
        XCTAssert(sut.spokenText == "инжене́ре")
    }
    
    func testGetSingleAccentedWithNilWordForm() throws {
        let word = wordService.findMatches(from: [39]).first!
        let sut = TypeSpeechExerciseViewModel(word: word, wordForm: nil, wordService: wordService)
        XCTAssert(sut.spokenText == "то́лько")
    }
    
    func testHint() throws {
        let sut = TypeSpeechExerciseViewModel(word: Word(), wordForm: WordForm(bare: "инженере", accented: "инжене'ре", form: .nounSingularPrepositional), wordService: wordService)
        XCTAssert(sut.hint.count > 0)
    }
}
