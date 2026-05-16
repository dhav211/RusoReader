import GRDB
import Foundation

class BookRepository {
    let databaseManager: DatabaseManager
    let fileStore: FileStore
    
    init(databaseManager: DatabaseManager, fileStore: FileStore) {
        self.databaseManager = databaseManager
        self.fileStore = fileStore
    }
    
    func saveBook(parsedBook: ParsedBook) -> Book? {
        do {
            return try databaseManager.userDataQueue.write { db in
                let coverImageUrl: URL? = try {
                    if let coverImage = parsedBook.book.coverImage {
                        return try fileStore.save(data: coverImage, fileName: "\(parsedBook.book.title.replacingOccurrences(of: " ", with: "-").lowercased())-cover-image\(parsedBook.book.coverImageFileType)")
                    } else {
                        return nil
                    }
                }()
                
                var book = DatabaseBook(name: parsedBook.book.title, author: parsedBook.book.author, cover_image_url: coverImageUrl?.path() ?? "", current_chapter: 1, isbn: parsedBook.book.isbn, uuid: parsedBook.book.uuid)
                
                try book.insert(db)
                
                var chapters = [DatabaseChapter]()
                for parsedChapter in parsedBook.chapters {
                    var chapter = DatabaseChapter(name: parsedChapter.title, index: Int64(parsedChapter.index), current_user_progress: 0, text: parsedChapter.text, book_id: book.id ?? 0)
                    try chapter.insert(db)
                    chapters.append(chapter)
                }
                
                return createBook(from: FetchedBookInfo(book: book, chapters: chapters))
            }
        } catch {
            print("Error saving book: \(error)")
            return nil
        }
    }
    
    func findBooksBy(title: String) -> [Book] {
        do {
            return try databaseManager.userDataQueue.read { db in
                let request = DatabaseBook
                    .filter(DatabaseBook.Columns.name.uppercased == title.uppercased())
                    .including(all: DatabaseBook.chapters)
                    .asRequest(of: FetchedBookInfo.self)
                
                return try FetchedBookInfo.fetchAll(db, request).map { fetchedBook in
                    return createBook(from: fetchedBook)
                }
            }
        } catch {
            print("Error loading book by title of \(title). Error: \(error)")
            return [Book]()
        }
    }
    
    /// Find a specific book by its ID
    /// - Parameter id: The ID of the book we are looking for
    /// - Returns: The book object with all chapters, ready to be read by the user
    func findBookBy(by id: Int) -> Book? {
        do {
            return try databaseManager.userDataQueue.read { db in
                let request = DatabaseBook
                    .filter(id: Int64(id))
                    .including(all: DatabaseBook.chapters)
                    .asRequest(of: FetchedBookInfo.self)
                
                guard let fetchedBook = try FetchedBookInfo.fetchOne(db, request) else { return nil }
                
                return createBook(from: fetchedBook)
            }
        } catch {
            print("Failed to find book by id: \(error)")
            return nil
        }
    }
    
    /// Used by the BookSelector, this loads just enough information about the book for the user to choose.
    /// - Returns: A link to every book the user has in the database
    func getAllBookLinks() -> [BookLink] {
        do {
            return try databaseManager.userDataQueue.read { db in
                let rows = try Row.fetchCursor(db, sql: "SELECT id, name, author, cover_image_url FROM books")
                
                var links = [BookLink]()
                
                while let row = try rows.next() {
                    links.append(BookLink(
                        bookId: row["id"] ?? 0,
                        title: row["name"] ?? "",
                        author: row["author"] ?? "",
                        coverImageURL: URL(string: row["cover_image_url"] ?? ""))
                    )
                }
                
                return links
            }
        } catch {
            print("Failed to create book links: \(error)")
            return [BookLink]()
        }
    }
    
    /// Convert the fetched book information, which is more or less a join table of the book and chapters, into an actual book object that can be read by the user
    /// - Parameter fetchBookInfo: The book and chapter information that was fetched from the database
    /// - Returns: A complete book object that will be used in the reader view
    private func createBook(from fetchBookInfo: FetchedBookInfo) -> Book {
        let chapters = fetchBookInfo.chapters.map { dbChapter in
            return Chapter(
                name: dbChapter.name,
                index: Int(dbChapter.index),
                currentUserProgress: Int(dbChapter.current_user_progress),
                text: dbChapter.text
            )
        }
        
        return Book(
            name: fetchBookInfo.book.name,
            author: fetchBookInfo.book.author,
            chapters: chapters,
            coverImageUrl: fetchBookInfo.book.cover_image_url,
            currentChapter: Int(fetchBookInfo.book.current_chapter),
            dateLastOpened: fetchBookInfo.book.date_last_opened,
            dateCreated: fetchBookInfo.book.date_created)
    }
}
