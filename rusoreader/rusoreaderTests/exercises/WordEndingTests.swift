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
        XCTAssert(sut.calculateResult(exerciseInput: "женщине").grade == .correct)
    }
    //
    
    func testРебёнкаAccusativeSingluarNoun() throws {
        let word = wordRepo.findMatches(by: [173]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "ребёнка", accented: "ребёнка", form: .nounSingularAccusative), wordService: wordService)
        XCTAssert(sut.calculateResult(exerciseInput: "ребёнка").grade == .correct)
    }
    
    func testDativeSingluarNounWithWhiteSpace() throws {
        let word = wordRepo.findMatches(by: [169]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "женщине", accented: "же'нщине", form: .nounSingularDative), wordService: wordService)
        XCTAssert(sut.calculateResult(exerciseInput: "женщине   ").grade == .correct)
    }
    
    func testDativeSingluarNounWithCapitalization() throws {
        let word = wordRepo.findMatches(by: [169]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "женщине", accented: "же'нщине", form: .nounSingularDative), wordService: wordService)
        XCTAssert(sut.calculateResult(exerciseInput: "Женщине").grade == .correct)
    }
    
    func testEndingForNounIsWrong() throws {
        let word = wordRepo.findMatches(by: [169]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "женщине", accented: "же'нщине", form: .nounSingularDative), wordService: wordService)
        XCTAssert(sut.calculateResult(exerciseInput: "женщина").grade == .incorrect)
    }
    
    func testStemForNounIsWrongButClose() throws {
        let word = wordRepo.findMatches(by: [169]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "женщине", accented: "же'нщине", form: .nounSingularDative), wordService: wordService)
        XCTAssert(sut.calculateResult(exerciseInput: "жинщине").grade == .almost)
    }
    
    func testStemForNounIsWrong() throws {
        let word = wordRepo.findMatches(by: [169]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "женщине", accented: "же'нщине", form: .nounSingularDative), wordService: wordService)
        XCTAssert(sut.calculateResult(exerciseInput: "жинщене").grade == .incorrect)
    }
    
    func testHighlightedDifferenceForРебёнкаAndРибёнка() throws {
        let word = wordRepo.findMatches(by: [173]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "ребёнка", accented: "ребёнка", form: .nounSingularAccusative), wordService: wordService)
        XCTAssert(sut.createHightlightedDifferenceInAnswer(answer: "рибёнка") == [1])
    }
    
    func testHighlightedDifferenceWithMissingLetter() throws {
        let word = wordRepo.findMatches(by: [173]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "ребёнка", accented: "ребёнка", form: .nounSingularAccusative), wordService: wordService)
        XCTAssert(sut.createHightlightedDifferenceInAnswer(answer: "рбёнка") == [1])
    }
    
    func testHighlightedDifferenceWithExtraLetter() throws {
        let word = wordRepo.findMatches(by: [173]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "ребёнка", accented: "ребёнка", form: .nounSingularAccusative), wordService: wordService)
        XCTAssert(sut.createHightlightedDifferenceInAnswer(answer: "реббёнка") == [3])
    }
    
    func testHighlightedDifferenceWithExtraLetterAndMissingLetter() throws {
        let word = wordRepo.findMatches(by: [173]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "ребёнка", accented: "ребёнка", form: .nounSingularAccusative), wordService: wordService)
        XCTAssert(sut.createHightlightedDifferenceInAnswer(answer: "реббнка") == [3])
    }
    
    func testHighlightedDifferenceWithExtraLetterAndIncorrectLetter() throws {
        let word = wordRepo.findMatches(by: [173]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "ребёнка", accented: "ребёнка", form: .nounSingularAccusative), wordService: wordService)
        XCTAssert(sut.createHightlightedDifferenceInAnswer(answer: "реббенка") == [3])
    }
    
    func testHighlightedDifferenceWithTooManyLetters() throws {
        let word = wordRepo.findMatches(by: [173]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "ребёнок", accented: "ребёнок", form: .nounSingularNominative), wordService: wordService)
        XCTAssert(sut.createHightlightedDifferenceInAnswer(answer: "риббёнса") == [1,3,5,6])
    }
    
    func testHighlightedDifferenceWithTooManyLettersAfterWord() throws {
        let word = wordRepo.findMatches(by: [173]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "ребёнок", accented: "ребёнок", form: .nounSingularNominative), wordService: wordService)
        XCTAssert(sut.createHightlightedDifferenceInAnswer(answer: "ребёноков") == [])
    }
    
    func testHighlightedDifferenceWithoutLetters() throws {
        let word = wordRepo.findMatches(by: [173]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "ребёнка", accented: "ребёнка", form: .nounSingularAccusative), wordService: wordService)
        XCTAssert(sut.createHightlightedDifferenceInAnswer(answer: "") == [0,1,2,3,4,5,6])
    }
    
    func testHighlightedDifferenceForMissingDoubleConsonant() throws {
        let word = wordRepo.findMatches(by: [1122]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "масса", accented: "ма'сса", form: .nounSingularAccusative), wordService: wordService)
        XCTAssert(sut.createHightlightedDifferenceInAnswer(answer: "маса") == [3])
    }
    
    func testHighlightedDifferenceForMissingDoubleVowelAtEnding() throws {
        let word = wordRepo.findMatches(by: [152]).first!
        
        let sut = WordEndingExerciseViewModel(word: word, wordForm: WordForm(bare: "более", accented: "бо'лее", form: .nounSingularAccusative), wordService: wordService)
        XCTAssert(sut.createHightlightedDifferenceInAnswer(answer: "боле") == [4])
    }
}
