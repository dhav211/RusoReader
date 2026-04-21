import XCTest
@testable import rusoreader

final class SelectionRangeTests: XCTestCase {
    func testFindSecondWordInFirstSentence() {
        let text = "Может быть, я когда-нибудь прилетела с другой планеты? Давно. И забыла об этом. Или меня родители пронесли контрабандой. В животе. Мне часто говорят, что я инопланетянка, но никто не может объяснить, в чем это проявляется."
        let selectionRange = SelectionRange(text: text, characterIndex: 7)
        XCTAssert(selectionRange.wordRange.location == 6)
        XCTAssert(selectionRange.wordRange.length == "быть".count)
        XCTAssert(selectionRange.sentenceRange.location == 0)
        XCTAssert(selectionRange.sentenceRange.length == "Может быть, я когда-нибудь прилетела с другой планеты?".count)
    }
    
    func testFindThirdWordInThirdSentence() {
        let text = "Может быть, я когда-нибудь прилетела с другой планеты? Давно. И забыла об этом. Или меня родители пронесли контрабандой. В животе. Мне часто говорят, что я инопланетянка, но никто не может объяснить, в чем это проявляется."
        let range = text.range(of: "И забыла об этом.")
        let sentenceStartIndex = text.distance(from: text.startIndex, to: range!.lowerBound)
        let checkIndex = sentenceStartIndex + 10
        
        let selectionRange = SelectionRange(text: text, characterIndex: checkIndex)
        
        XCTAssert(selectionRange.wordRange.location == sentenceStartIndex + 9)
        XCTAssert(selectionRange.wordRange.length == 2)
        XCTAssert(selectionRange.sentenceRange.location == sentenceStartIndex)
        XCTAssert(selectionRange.sentenceRange.length == "И забыла об этом.".count)
    }
    
    func testSentenceThatBeginsWithDash() {
        let text = """
        Видимо, поэтому я несколько десоциализирована. Я не понимаю многих поступков людей, которые меня окружают, а они в свою очередь настороженно относятся ко мне, несмотря на ту симпатию, которую мы друг к другу испытываем в большинстве случаев. Поэтому я почти всегда одинока, несмотря на большое количество замечательных, дорогих мне людей, меня окружающих. Видимо, я с очень далекой планеты, поэтому мои земляки редки на Земле. Я мечтаю встретить своего сопланетника. Наверное, он так же, как я, бродит по планете Земля, грустит и мечтает встретить меня. Маленький мой, как же нам найти друг друга? Мне немножко страшно, вдруг этого никогда не произойдет.
        
        — Да, глупость сморозил. Вкалывать нам еще и вкалывать. А о пенсии я только мечтаю. Ну должна же быть у человека мечта! Без мечты и жизнь не в жизнь.
        """
        let range = text.range(of: "— Да, глупость сморозил.")
        let sentenceStartIndex = text.distance(from: text.startIndex, to: range!.lowerBound)
        let checkIndex = sentenceStartIndex + 10
        let selectionRange = SelectionRange(text: text, characterIndex: checkIndex)
        XCTAssert(selectionRange.sentenceRange.location == sentenceStartIndex)
        XCTAssert(selectionRange.sentenceRange.length == "— Да, глупость сморозил.".count)
    }
    
    func testSentenceBeginningWithTree() {
        let text = """
            — Да, глупость сморозил. Вкалывать нам еще и вкалывать. А о пенсии я только мечтаю. Ну должна же быть у человека мечта! Без мечты и жизнь не в жизнь.
            
            «Романтик!» — подумал Матвей. Впрочем, он и сам был идеалистом, иначе не служил бы в отделе № 7 Особого управления МВД РФ. Других людей «семерка» отторгала.
            """
        let range = text.range(of: "«Романтик!» — подумал Матвей.")
        let sentenceStartIndex = text.distance(from: text.startIndex, to: range!.lowerBound)
        let checkIndex = sentenceStartIndex + 15
        let selectionRange = SelectionRange(text: text, characterIndex: checkIndex)
        XCTAssert(selectionRange.sentenceRange.location == sentenceStartIndex)
        XCTAssert(selectionRange.sentenceRange.length == "«Романтик!» — подумал Матвей.".count)
    }
    
    func testOddBug() {
        let text = """
            — Да, глупость сморозил. Вкалывать нам еще и вкалывать. А о пенсии я только мечтаю. Ну должна же быть у человека мечта! Без мечты и жизнь не в жизнь.
            
            «Романтик!» — подумал Матвей. Впрочем, он и сам был идеалистом, иначе не служил бы в отделе № 7 Особого управления МВД РФ. Других людей «семерка» отторгала.
            """
        let range = text.range(of: "Других людей «семерка» отторгала.")
        let sentenceStartIndex = text.distance(from: text.startIndex, to: range!.lowerBound)
        let checkIndex = sentenceStartIndex + 8
        let selectionRange = SelectionRange(text: text, characterIndex: checkIndex)

        XCTAssert(selectionRange.sentenceRange.location == sentenceStartIndex)
        XCTAssert(selectionRange.sentenceRange.length == "Других людей «семерка» отторгала.".count)
    }
}
