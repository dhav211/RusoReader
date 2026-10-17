import XCTest
@testable import rusoreader

final class HighlightedAnswerTests: XCTestCase {
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    private func addAttributesToWord(answer: String, indices: [Int]) -> NSMutableAttributedString {
        let attributedAnswer = NSMutableAttributedString(string: answer)
        let defaultFont = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        
        for index in indices {
            attributedAnswer.addAttributes(
                [
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .font: UIFont.boldSystemFont(ofSize: defaultFont.pointSize)
                ],
                range: NSRange(location: index, length: 1))
        }
        
        return attributedAnswer
    }
    
    func testHighlightedDifferenceForAllWrong() throws {
        let sut = NSMutableAttributedString.highlightedAnswer(from: "ж", wordForm: WordForm(bare: "ребёнка", accented: "ребёнка", form: .nounSingularAccusative))
        let expected = addAttributesToWord(answer: "ребёнка", indices: [0,1,2,3,4,5,6])
        XCTAssert(expected.isEqual(to: sut))
    }
    
    func testHighlightedDifferenceForРебёнкаAndРибёнка() throws {
        let sut = NSMutableAttributedString.highlightedAnswer(from: "рибёнка", wordForm: WordForm(bare: "ребёнка", accented: "ребёнка", form: .nounSingularAccusative))
        let expected = addAttributesToWord(answer: "ребёнка", indices: [1])
        XCTAssert(expected.isEqual(to: sut))
    }
    
    func testHighlightedDifferenceForДетьмиAndДетями() throws {
        let sut = NSMutableAttributedString.highlightedAnswer(from: "детями", wordForm: WordForm(bare: "детьми,ребятами", accented: "детьми',ребя'тами", form: .nounSingularAccusative))
        let expected = addAttributesToWord(answer: "детьми", indices: [3])
        XCTAssert(expected.isEqual(to: sut))
    }
    
    func testHighlightedDifferenceWithMissingLetter() throws {
        let sut = NSMutableAttributedString.highlightedAnswer(from: "рбёнка", wordForm: WordForm(bare: "ребёнка", accented: "ребёнка", form: .nounSingularAccusative))
        let expected = addAttributesToWord(answer: "ребёнка", indices: [1])
        XCTAssert(expected.isEqual(to: sut))
    }
    
    func testHighlightedDifferenceWithExtraLetter() throws {
        let sut = NSMutableAttributedString.highlightedAnswer(from: "реббёнка", wordForm: WordForm(bare: "ребёнка", accented: "ребёнка", form: .nounSingularAccusative))
        let expected = addAttributesToWord(answer: "ребёнка", indices: [3])
        XCTAssert(expected.isEqual(to: sut))
    }
    
    func testNoHighlightedDifferenceWithoutЁ() throws {
        let sut = NSMutableAttributedString.highlightedAnswer(from: "ребенка", wordForm: WordForm(bare: "ребёнка", accented: "ребёнка", form: .nounSingularAccusative))
        let expected = addAttributesToWord(answer: "ребёнка", indices: [])
        XCTAssert(expected.isEqual(to: sut))
    }
    
    func testHighlightedDifferenceWithExtraLetterAndMissingLetter() throws {
        let sut = NSMutableAttributedString.highlightedAnswer(from: "реббнка", wordForm: WordForm(bare: "ребёнка", accented: "ребёнка", form: .nounSingularAccusative))
        let expected = addAttributesToWord(answer: "ребёнка", indices: [3])
        XCTAssert(expected.isEqual(to: sut))
    }
    
    func testHighlightedDifferenceWithExtraLetterAndIncorrectLetter() throws {
        let sut = NSMutableAttributedString.highlightedAnswer(from: "реббенка", wordForm: WordForm(bare: "ребёнка", accented: "ребёнка", form: .nounSingularAccusative))
        let expected = addAttributesToWord(answer: "ребёнка", indices: [3])
        XCTAssert(expected.isEqual(to: sut))
    }
    
    func testHighlightedDifferenceWithTooManyLetters() throws {
        let sut = NSMutableAttributedString.highlightedAnswer(from: "риббёнса", wordForm: WordForm(bare: "ребёнка", accented: "ребёнка", form: .nounSingularAccusative))
        let expected = addAttributesToWord(answer: "ребёнка", indices: [1,3,5])
        XCTAssert(expected.isEqual(to: sut))
    }
    
    func testHighlightedDifferenceWithTooManyLettersAfterWord() throws {
        let sut = NSMutableAttributedString.highlightedAnswer(from: "ребёноков", wordForm: WordForm(bare: "ребёнка", accented: "ребёнка", form: .nounSingularAccusative))
        let expected = addAttributesToWord(answer: "ребёнка", indices: [5, 6])
        XCTAssert(expected.isEqual(to: sut))
    }
    
    func testHighlightedDifferenceWithoutLetters() throws {
        let sut = NSMutableAttributedString.highlightedAnswer(from: "", wordForm: WordForm(bare: "ребёнка", accented: "ребёнка", form: .nounSingularAccusative))
        let expected = addAttributesToWord(answer: "ребёнка", indices: [0,1,2,3,4,5,6])
        XCTAssert(expected.isEqual(to: sut))
    }
    
    func testHighlightedDifferenceForMissingDoubleConsonant() throws {
        let sut = NSMutableAttributedString.highlightedAnswer(from: "маса", wordForm: WordForm(bare: "масса", accented: "ма'сса", form: .nounSingularAccusative))
        let expected = addAttributesToWord(answer: "масса", indices: [3])
        XCTAssert(expected.isEqual(to: sut))
    }
    
    func testHighlightedDifferenceForMissingDoubleVowelAtEnding() throws {
        let sut = NSMutableAttributedString.highlightedAnswer(from: "боле", wordForm: WordForm(bare: "более", accented: "бо'лее", form: .nounSingularAccusative))
        let expected = addAttributesToWord(answer: "более", indices: [4])
        XCTAssert(expected.isEqual(to: sut))
    }
}
