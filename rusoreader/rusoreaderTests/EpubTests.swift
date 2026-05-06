import XCTest
@testable import rusoreader
import GRDB

final class EpubTests: XCTestCase {
    var databaseManager: DatabaseManager!
    var bookRepo: BookRepository!
    
    override func setUpWithError() throws {
        let queue = try DatabaseQueue()
        databaseManager = DatabaseManager(userDataQueue: queue)
        bookRepo = BookRepository(databaseManager: databaseManager)
    }

    override func tearDownWithError() throws {
        databaseManager = nil
    }

    func testAddingBookToDB() throws {
        var book = DatabaseBook(name: "Harry Potter", file_url: "file://path/to/book.epub", cover_image_url: "file://path/to/image.png", current_chapter: 0, isbn: "978-5-08-004546-2", uuid: "4a2b9ca9-b0d8-11e3-b4aa-0025905a0812")
        
        databaseManager.userDataQueue.inDatabase { db in
            do {
                try book.insert(db)
            } catch {
                return XCTFail("Couldn't insert book into database. \(error)")
            }
        }

        var chapters = [DatabaseChapter]()
        if let bookId = book.id {
            chapters.append(DatabaseChapter(id: nil, name: "Chapter 1", index: 1, current_user_progress: 0, url: "", book_id: bookId))
            chapters.append(DatabaseChapter(id: nil, name: "Chapter 2", index: 2, current_user_progress: 0, url: "", book_id: bookId))
            chapters.append(DatabaseChapter(id: nil, name: "Chapter 3", index: 3, current_user_progress: 0, url: "", book_id: bookId))
            chapters.append(DatabaseChapter(id: nil, name: "Chapter 4", index: 4, current_user_progress: 0, url: "", book_id: bookId))
            
            databaseManager.userDataQueue.inDatabase { db in
                do {
                    for var chapter in chapters {
                        try chapter.insert(db)
                    }
                } catch {
                    return XCTFail("Couldn't insert chapter into database. \(error)")
                }
            }
        }
        
        let books = bookRepo.findBooksBy(title: "Harry Potter")
        
        XCTAssert(books.count == 1)
        
        if let firstBook = books.first {
            XCTAssert(firstBook.name == "Harry Potter")
            XCTAssert(firstBook.chapters.count == 4)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
