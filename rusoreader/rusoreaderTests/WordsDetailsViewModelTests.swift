import XCTest
@testable import rusoreader

final class WordsDetailsViewModelTests: XCTestCase {
    var databaseManager: DatabaseManager!
    var wordRepo: WordRepository!
    var wordService: WordService!
    var sentenceRepo: SentenceRepository!
    var dictionaryRepo: DictionaryRepository!
    
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
        wordService = nil
    }
    
    func testAddStressToSentence() throws {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .noun,
            level: "",
            ranking: 1,
            noun: Noun(gender: .female, partner: "", animate: true, indeclinable: false, plurality: .neither),
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        
        let stressed = sut.addStressToSentence(sentence: "В шка'фу виси'т оде'жда.")
        XCTAssert(stressed == "В шка́фу виси́т оде́жда.")
    }
    
    func testAddStressToOneWordSentence() throws {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .noun,
            level: "",
            ranking: 1,
            noun: Noun(gender: .female, partner: "", animate: true, indeclinable: false, plurality: .neither),
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        let stressed = sut.addStressToSentence(sentence: "оде'жда.")
        XCTAssert(stressed == "оде́жда.")
    }
    
    func testNoStressInSentence() throws {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .noun,
            level: "",
            ranking: 1,
            noun: Noun(gender: .female, partner: "", animate: true, indeclinable: false, plurality: .neither),
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        let stressed = sut.addStressToSentence(sentence: "На заводе")
        XCTAssert(stressed == "На заводе")
    }
    
    // MARK: - Noun tests
    
    func testNounFemaleAnimate() throws {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .noun,
            level: "",
            ranking: 1,
            noun: Noun(gender: .female, partner: "", animate: true, indeclinable: false, plurality: .neither),
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)

        XCTAssertEqual(sut.getWordInformation(), "Noun, female, animate")
    }

    func testNounFemaleInanimate() throws {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .noun,
            level: "",
            ranking: 1,
            noun: Noun(gender: .female, partner: "", animate: false, indeclinable: false, plurality: .neither),
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)

        XCTAssertEqual(sut.getWordInformation(), "Noun, female, inanimate")
    }

    func testNounMaleAnimate() throws {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .noun,
            level: "",
            ranking: 1,
            noun: Noun(gender: .male, partner: "", animate: true, indeclinable: false, plurality: .neither),
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)

        XCTAssertEqual(sut.getWordInformation(), "Noun, male, animate")
    }

    func testNounMaleInanimate() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .noun,
            level: "",
            ranking: 1,
            noun: Noun(gender: .male, partner: "", animate: false, indeclinable: false, plurality: .neither),
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)

        XCTAssertEqual(sut.getWordInformation(), "Noun, male, inanimate")
    }

    func testNounNeuterAnimate() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .noun,
            level: "",
            ranking: 1,
            noun: Noun(gender: .neuter, partner: "", animate: true, indeclinable: false, plurality: .neither),
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)

        XCTAssertEqual(sut.getWordInformation(), "Noun, neuter, animate")
    }

    func testNounNeuterInanimate() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .noun,
            level: "",
            ranking: 1,
            noun: Noun(gender: .neuter, partner: "", animate: false, indeclinable: false, plurality: .neither),
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)

        XCTAssertEqual(sut.getWordInformation(), "Noun, neuter, inanimate")
    }

    func testNounBothGenderAnimate() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .noun,
            level: "",
            ranking: 1,
            noun: Noun(gender: .both, partner: "", animate: true, indeclinable: false, plurality: .neither),
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)

        XCTAssertEqual(sut.getWordInformation(), "Noun, male & female, animate")
    }

    func testNounBothGenderInanimate() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .noun,
            level: "",
            ranking: 1,
            noun: Noun(gender: .both, partner: "", animate: false, indeclinable: false, plurality: .neither),
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)

        XCTAssertEqual(sut.getWordInformation(), "Noun, male & female, inanimate")
    }

    func testAllNilButHasNounType() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .noun,
            level: "",
            ranking: 1,
            noun: nil,
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)

        XCTAssertEqual(sut.getWordInformation(), "Noun")
    }

    // MARK: - Verb tests

    func testVerb_withPerfectiveAspect() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .verb,
            level: "",
            ranking: 1,
            noun: nil,
            verb: Verb(aspect: .perfective, partners: [String]()),
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)

        XCTAssertEqual(sut.getWordInformation(), "Verb, perfective")
    }

    func testVerb_withImperfectiveAspect() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .verb,
            level: "",
            ranking: 1,
            noun: nil,
            verb: Verb(aspect: .imperfective, partners: [String]()),
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)

        XCTAssertEqual(sut.getWordInformation(), "Verb, imperfective")
    }

    /// When `word.type == .verb` but `word.verb` is nil, only "Verb" should be appended.
    func testVerb_withNilVerbDetails_returnsOnlyVerb() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .verb,
            level: "",
            ranking: 1,
            noun: nil,
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)

        XCTAssertEqual(sut.getWordInformation(), "Verb")
    }

    // MARK: - Other word types

    func testAdjective() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .adjective,
            level: "",
            ranking: 1,
            noun: nil,
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)

        XCTAssertEqual(sut.getWordInformation(), "Adjective")
    }

    func testAdverb() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .adverb,
            level: "",
            ranking: 1,
            noun: nil,
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)

        XCTAssertEqual(sut.getWordInformation(), "Adverb")
    }

    func testOther() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .other,
            level: "",
            ranking: 1,
            noun: nil,
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)

        XCTAssertEqual(sut.getWordInformation(), "")
    }
    
    // MARK: - Top 10 (0...10)
 
    func testRanking_zero_returnsTop10() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .other,
            level: "",
            ranking: 1,
            noun: nil,
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        XCTAssertEqual(sut.getRankingTitle(), "Top 10")
    }
 
    func testRanking_ten_returnsTop10() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .other,
            level: "",
            ranking: 1,
            noun: nil,
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        XCTAssertEqual(sut.getRankingTitle(), "Top 10")
    }
 
    // MARK: - Top 100 (11...100)
 
    func testRanking_eleven_returnsTop100() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .other,
            level: "",
            ranking: 11,
            noun: nil,
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        XCTAssertEqual(sut.getRankingTitle(), "Top 100")
    }
 
    func testRanking_oneHundred_returnsTop100() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .other,
            level: "",
            ranking: 100,
            noun: nil,
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        XCTAssertEqual(sut.getRankingTitle(), "Top 100")
    }
 
    // MARK: - Top {multiple of 500} (101...10_000)
 
    func testRanking_oneHundredOne_returnsTop500() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .other,
            level: "",
            ranking: 101,
            noun: nil,
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        XCTAssertEqual(sut.getRankingTitle(), "Top 500")
    }
 
    func testRanking_fourNinetyNine_returnsTop500() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .other,
            level: "",
            ranking: 499,
            noun: nil,
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        XCTAssertEqual(sut.getRankingTitle(), "Top 500")
    }
 
    func testRanking_exactlyFiveHundred_returnsTop1000() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .other,
            level: "",
            ranking: 500,
            noun: nil,
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        XCTAssertEqual(sut.getRankingTitle(), "Top 500")
    }
    
    func testRanking_exactlyOneThousand_returnsTop1000() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .other,
            level: "",
            ranking: 1000,
            noun: nil,
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        XCTAssertEqual(sut.getRankingTitle(), "Top 1000")
    }
 
    func testRanking_documentedExample_returnsTop25000() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .other,
            level: "",
            ranking: 23503,
            noun: nil,
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        XCTAssertEqual(sut.getRankingTitle(), "Top 25000")
    }
 
    func testRanking_nineNineNineNine_returnsTop10000() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .other,
            level: "",
            ranking: 9999,
            noun: nil,
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        XCTAssertEqual(sut.getRankingTitle(), "Top 10000")
    }
 
    func testRanking_exactlyTenThousand_returnsTop10500() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .other,
            level: "",
            ranking: 10_000,
            noun: nil,
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        XCTAssertEqual(sut.getRankingTitle(), "Top 10000")
    }
 
    // MARK: - Top {multiple of 5000} (10_001...50_000)
 
    func testRanking_tenThousandOne_returnsTop15000() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .other,
            level: "",
            ranking: 10_001,
            noun: nil,
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        XCTAssertEqual(sut.getRankingTitle(), "Top 15000")
    }
 
    func testRanking_exactlyFifteenThousand_returnsTop20000() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .other,
            level: "",
            ranking: 15_000,
            noun: nil,
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        XCTAssertEqual(sut.getRankingTitle(), "Top 15000")
    }
 
    func testRanking_fortyNineNineNineNine_returnsTop50000() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .other,
            level: "",
            ranking: 49_999,
            noun: nil,
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        XCTAssertEqual(sut.getRankingTitle(), "Top 50000")
    }
 
    func testRanking_exactlyFiftyThousand_returnsTop55000() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .other,
            level: "",
            ranking: 50_000,
            noun: nil,
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        XCTAssertEqual(sut.getRankingTitle(), "Top 50000")
    }
 
    // MARK: - Very rarely used (out of range)
 
    func testRanking_fiftyThousandOne_returnsVeryRarelyUsed() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .other,
            level: "",
            ranking: 50_001,
            noun: nil,
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        XCTAssertEqual(sut.getRankingTitle(), "Very rarely used")
    }
 
    func testRanking_negativeOne_returnsVeryRarelyUsed() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .other,
            level: "",
            ranking: -1,
            noun: nil,
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        XCTAssertEqual(sut.getRankingTitle(), "Very rarely used")
    }
 
    func testRanking_largeNegative_returnsVeryRarelyUsed() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .other,
            level: "",
            ranking: -100,
            noun: nil,
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        XCTAssertEqual(sut.getRankingTitle(), "Very rarely used")
    }
 
    func testRanking_veryLargePositive_returnsVeryRarelyUsed() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .other,
            level: "",
            ranking: Int.max,
            noun: nil,
            verb: nil,
            forms: [String:String](),
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        XCTAssertEqual(sut.getRankingTitle(), "Very rarely used")
    }
    func testNounTableLabelCellsOutrankActualRussianWords() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .noun,
            level: "",
            ranking: 1,
            noun: nil,
            verb: nil,
            forms: [
                "ru_noun_sg_nom": "кот",
                "ru_noun_pl_nom": "коты",
                "ru_noun_sg_gen": "кота",
                "ru_noun_pl_gen": "котов",
                "ru_noun_sg_dat": "коту",
                "ru_noun_pl_dat": "котам",
                "ru_noun_sg_acc": "кота",
                "ru_noun_pl_acc": "котов",
                "ru_noun_sg_inst": "котом",
                "ru_noun_pl_inst": "котами",
                "ru_noun_sg_prep": "коте",
                "ru_noun_pl_prep": "котах"
            ],
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        let data = sut.createGrammarFormTableData(grammarTableType: .noun)
        XCTAssertEqual(sut.getLongestRows(grammarFormTableData: data), [1, 0, 0, 0, 0, 0, 0])
    }

    func testVerbTablePronounLabelsUsuallyLoseButOneWins() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .verb,
            level: "",
            ranking: 1,
            noun: nil,
            verb: nil,
            forms: [
                "ru_verb_presfut_sg1": "иду",
                "ru_verb_presfut_sg2": "идёшь",
                "ru_verb_presfut_sg3": "идёт",
                "ru_verb_presfut_pl1": "идём",
                "ru_verb_presfut_pl2": "идёте",
                "ru_verb_presfut_pl3": "идут"
            ],
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        let data = sut.createGrammarFormTableData(grammarTableType: .verb)
        XCTAssertEqual(sut.getLongestRows(grammarFormTableData: data), [1, 1, 0, 1, 1, 1])
    }

    func testVerbPastTableLabelsWinEveryRow() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .verb,
            level: "",
            ranking: 1,
            noun: nil,
            verb: nil,
            forms: [
                "ru_verb_past_m": "делал",
                "ru_verb_past_f": "делала",
                "ru_verb_past_n": "делало",
                "ru_verb_past_pl": "делали"
            ],
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        let data = sut.createGrammarFormTableData(grammarTableType: .verbPast)
 
        XCTAssertEqual(sut.getLongestRows(grammarFormTableData: data), [0, 0, 0, 0])
    }

    func testVerbImperativeTableWordsBeatShortLabels() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .verb,
            level: "",
            ranking: 1,
            noun: nil,
            verb: nil,
            forms: [
                "ru_verb_imperative_sg": "иди",
                "ru_verb_imperative_pl": "идите"
            ],
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        let data = sut.createGrammarFormTableData(grammarTableType: .verbImperative)
 
        XCTAssertEqual(sut.getLongestRows(grammarFormTableData: data), [1, 1])
    }

    func testNounTable_missingWordForms_defaultsToEmptyCellsNoCrash() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .verb,
            level: "",
            ranking: 1,
            noun: nil,
            verb: nil,
            forms: [:],
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        let data = sut.createGrammarFormTableData(grammarTableType: .noun)
 
        XCTAssertEqual(sut.getLongestRows(grammarFormTableData: data), [1, 0, 0, 0, 0, 0, 0])
    }

    func testVerbParticiples_unhandledTypeFallsThroughToPlaceholder() {
        let word = Word(
            id: 0,
            bare: "",
            accented: "",
            type: .verb,
            level: "",
            ranking: 1,
            noun: nil,
            verb: nil,
            forms: [
                "ru_verb_participle_present_active": "делающий"
            ],
            translations: [String]()
        )
        let sut = WordDetailsViewModel(word: word, wordService: wordService)
        let data = sut.createGrammarFormTableData(grammarTableType: .verbParticiples)
 
        XCTAssertEqual(sut.getLongestRows(grammarFormTableData: data), [0])
    }

}
