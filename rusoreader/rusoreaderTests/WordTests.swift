import XCTest
@testable import rusoreader

final class WordTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFindAdjectiveBase() throws {
        XCTAssert(WordUtils.findAdjectiveBase(for: "Уникальный") == "Уникальн")
        XCTAssert(WordUtils.findAdjectiveBase(for: "холодному") == "холодн")
        
    }

    func testIsVowel() throws {
        XCTAssert(CyrillicUtils.isVowel(letter: "а") == true)
        XCTAssert(CyrillicUtils.isVowel(letter: "А") == true)
        XCTAssert(CyrillicUtils.isVowel(letter: "н") == false)
        XCTAssert(CyrillicUtils.isVowel(letter: "е") == true)
        XCTAssert(CyrillicUtils.isVowel(letter: "a") == false) // That's an latin a
    }
}

