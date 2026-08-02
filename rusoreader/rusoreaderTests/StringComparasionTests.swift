import XCTest
@testable import rusoreader

final class StringComparasionTests: XCTestCase {
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    func testBookBok() throws {
        XCTAssert(StringComparasion.compare("book", "bok") == 1)
    }
    
    func testBookBoook() throws {
        XCTAssert(StringComparasion.compare("book", "boook") == 1)
    }
    
    func testEmpty() throws {
        XCTAssert(StringComparasion.compare("", "") == 0)
    }
}
