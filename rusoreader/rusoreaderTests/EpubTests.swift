import XCTest
@testable import rusoreader
import GRDB

final class EpubTests: XCTestCase {
    var databaseManager: DatabaseManager!
    var bookRepo: BookRepository!
    var testDirectory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    var fileStore: FileStore!
    var fileManager: FileManager!
    
    override func setUpWithError() throws {
        let queue = try DatabaseQueue()
        fileManager = FileManager()
        databaseManager = DatabaseManager(userDataQueue: queue)
        try? FileManager.default.createDirectory(at: testDirectory, withIntermediateDirectories: true)
        fileStore = FileStore(directory: testDirectory)
        bookRepo = BookRepository(databaseManager: databaseManager, fileStore: fileStore)
    }

    override func tearDownWithError() throws {
        databaseManager = nil
        bookRepo = nil
        try? fileManager.removeItem(at: testDirectory)
        fileStore = nil
        fileManager = nil
    }
    
    func testSaveEpubToDB() throws {
        let parser = EpubParser()
        if let chekhovBookURL = Bundle.main.url(forResource: "chekhov", withExtension: "epub") {
            let book = parser.parse(from: chekhovBookURL)
            
            XCTAssert(book?.chapters.count == 13)
            XCTAssert(book?.book.title == "Лошадиная фамилия. Рассказы и водевили")
            
            let _ = try bookRepo.saveBook(parsedBook: book!)
            let fetchedBook = bookRepo.findBooksBy(title: "Лошадиная фамилия. Рассказы и водевили").first!
            
            //XCTAssert(fetchedBook.chapters.count == 13)
            XCTAssertNotNil(fetchedBook)
        }
        
        if let wizardBookURL = Bundle.main.url(forResource: "wizard", withExtension: "epub") {
            let book = parser.parse(from: wizardBookURL)
            
            let _ = try bookRepo.saveBook(parsedBook: book!)
            if let fetchedBook = bookRepo.findBooksBy(title: "Волшебник Изумрудного города (с иллюстрациями) иг-1").first {
                XCTAssert(fetchedBook.name == "Волшебник Изумрудного города (с иллюстрациями) иг-1")
                XCTAssert(fetchedBook.author == "Александр Мелентьевич Волков")
            } else {
                XCTFail()
            }
        
        }
    }
    
    func testBookLinks() throws {
        try testSaveEpubToDB()
        
        let links = bookRepo.getAllBookLinks()
        
        XCTAssert(links.isEmpty == false)
    }
    
    func testFindBookById() throws {
        try testSaveEpubToDB()
        if let book = try bookRepo.findBookBy(by: 1) {
            XCTAssert(book.name == "Лошадиная фамилия. Рассказы и водевили")
        } else {
            XCTFail()
        }
    }

    func testDeleteBook() throws {
        let parser = EpubParser()
        if let chekhovBookURL = Bundle.main.url(forResource: "chekhov", withExtension: "epub") {
            let book = parser.parse(from: chekhovBookURL)
            
            let _ = try bookRepo.saveBook(parsedBook: book!)
        }
        
        let book = try bookRepo.findBookBy(by: 1)
        
        try bookRepo.removeBook(by: book!.id)
        
        if try bookRepo.findBookBy(by: 1) != nil {
            XCTFail()
        }
        
        do {
            let _ = try fileStore.load(fileName: book?.coverImageUrl ?? "")
            XCTFail()
        } catch {
            print("No book found at ID 1, it's been deleted")
        }
    }
    
    func testUpdateBook() throws {
        let parser = EpubParser()
        if let chekhovBookURL = Bundle.main.url(forResource: "chekhov", withExtension: "epub") {
            let book = parser.parse(from: chekhovBookURL)
            let _ = try bookRepo.saveBook(parsedBook: book!)
            
            if let foundBook = try bookRepo.findBookBy(by: 1) {
                do {
                    try bookRepo.updateBookInformation(by: foundBook.id, title: "Changed Title", author: nil)
                } catch {
                    XCTFail()
                }
            }
            
            if let updatedFoundBook = try bookRepo.findBookBy(by: 1) {
                XCTAssert(updatedFoundBook.author == "Антон Павлович Чехов")
                XCTAssert(updatedFoundBook.name == "Changed Title")
            }
        }
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
