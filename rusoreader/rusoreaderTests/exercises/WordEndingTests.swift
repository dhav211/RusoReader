import XCTest
@testable import rusoreader

final class WordEndingTests: XCTestCase {
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
    
    func testDativeSingluarNoun() throws {
        let word = wordRepo.findMatches(by: [169]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "женщине", accented: "же'нщине", form: .nounSingularDative), wordService: wordService)
        XCTAssert(sut.calculateResult( "женщине").grade == .correct)
    }
    //
    
    func testРебёнкаAccusativeSingluarNoun() throws {
        let word = wordRepo.findMatches(by: [173]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "ребёнка", accented: "ребёнка", form: .nounSingularAccusative), wordService: wordService)
        XCTAssert(sut.calculateResult( "ребёнка").grade == .correct)
    }
    
    func testРебёнкаWithoutЁ() throws {
        let word = wordRepo.findMatches(by: [173]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "ребёнка", accented: "ребёнка", form: .nounSingularAccusative), wordService: wordService)
        XCTAssert(sut.calculateResult( "ребенка").grade == .correct)
    }
    
    
    func testDativeSingluarNounWithWhiteSpace() throws {
        let word = wordRepo.findMatches(by: [169]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "женщине", accented: "же'нщине", form: .nounSingularDative), wordService: wordService)
        XCTAssert(sut.calculateResult( "женщине   ").grade == .correct)
    }
    
    func testDativeSingluarNounWithCapitalization() throws {
        let word = wordRepo.findMatches(by: [169]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "женщине", accented: "же'нщине", form: .nounSingularDative), wordService: wordService)
        XCTAssert(sut.calculateResult( "Женщине").grade == .correct)
    }
    
    func testEndingForNounIsWrong() throws {
        let word = wordRepo.findMatches(by: [169]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "женщине", accented: "же'нщине", form: .nounSingularDative), wordService: wordService)
        XCTAssert(sut.calculateResult( "женщина").grade == .incorrect)
    }
    
    func testStemForNounIsWrongButClose() throws {
        let word = wordRepo.findMatches(by: [169]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "женщине", accented: "же'нщине", form: .nounSingularDative), wordService: wordService)
        XCTAssert(sut.calculateResult( "жинщине").grade == .almost)
    }
    
    func testStemForNounIsWrong() throws {
        let word = wordRepo.findMatches(by: [169]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "женщине", accented: "же'нщине", form: .nounSingularDative), wordService: wordService)
        XCTAssert(sut.calculateResult( "жинщене").grade == .incorrect)
    }
    
    func testРебёнкаPrepositionalPluralNoun() throws {
        let word = wordRepo.findMatches(by: [173]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "детях,ребятах", accented: "де'тях,ребя'тах", form: .nounPluralPrepositional), wordService: wordService)
        XCTAssert(sut.calculateResult("детях").grade == .correct)
    }
    
    func testРебёнкаPrepositionalPluralNounSecondForm() throws {
        let word = wordRepo.findMatches(by: [173]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "детях,ребятах", accented: "ребёнка", form: .nounPluralPrepositional), wordService: wordService)
        XCTAssert(sut.calculateResult("ребятах").grade == .correct)
    }
    
    func testCleanAnswerBlank() throws {
        let sut = WordEndingExerciseViewModel(word: Word(), wordForm: WordForm(), wordService: wordService)
        XCTAssert(sut.cleanAnswerInput("") == "")
    }
    
    func testCleanAnswerSpaces() throws {
        let sut = WordEndingExerciseViewModel(word: Word(), wordForm: WordForm(), wordService: wordService)
        XCTAssert(sut.cleanAnswerInput("   ") == "")
    }
}
