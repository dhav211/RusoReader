import GRDB
import Foundation

enum BookRepositoryError: Error, LocalizedError {
    case notFound(id: Int)
    
    var errorDescription: String? {
        switch self {
        case .notFound(let id):
            return "Book with id \(id) was not found"
        }
    }
}

class BookRepository {
    let databaseManager: DatabaseManager
    let fileStore: FileStore
    
    init(databaseManager: DatabaseManager, fileStore: FileStore = FileStore(directory: .documentsDirectory)) {
        self.databaseManager = databaseManager
        self.fileStore = fileStore
    }
    
    /// Once a book has been parsed we can save it to the database for retrieval
    /// - Parameter parsedBook: The output from the EbookParser, this will contain the book and the chapters
    /// - Returns: A complete book object, this return will be useful for opening a book immediately after the user as added it
    func saveBook(parsedBook: ParsedBook) throws -> BookLink {
            return try databaseManager.userDataQueue.write { db in
                // We are creating a url to the saved cover image, this is a different url from the cover image in the epub. If there is no cover image in the book we will just skip past it, the cover image isn't required
                let coverImageUrl: String = try {
                    if let coverImage = parsedBook.book.coverImage {
                        let fileName = "\(parsedBook.book.isbn)-cover-image\(parsedBook.book.coverImageFileType)"
                        try fileStore.save(data: coverImage, fileName: fileName)
                        return fileName
                    } else {
                        return ""
                    }
                }()
                
                // The rest of this method is saving the parsed book into the database. The book needs to be inserted first so the chapters can get the generated ID for foreign keys
                
                var book = DatabaseBook(name: parsedBook.book.title, author: parsedBook.book.author, cover_image_url: coverImageUrl, current_chapter: 1, isbn: parsedBook.book.isbn, uuid: parsedBook.book.uuid)
                
                try book.insert(db)
                
                var chapters = [DatabaseChapter]()
                for parsedChapter in parsedBook.chapters {
                    var chapter = DatabaseChapter(name: parsedChapter.title, index: Int64(parsedChapter.index), current_user_progress: 0, text: parsedChapter.text, book_id: book.id ?? 0)
                    try chapter.insert(db)
                    chapters.append(chapter)
                }
                
                return BookLink(bookId: Int(book.id ?? 0), title: book.name, author: book.author, coverImageURL: book.cover_image_url ?? "")
            }
    }
    
    /// Find a collection of books with the same title, this method is possibly never used. It was created for my testing of accessing books
    /// - Parameter title: The title of the book(s) you wish the find
    /// - Returns: An array of books from the database, will return an empty array if nothing is found
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
    /// - Returns: The book object with all chapters, ready to be read by the user. Will return nil if nothing is found.
    func findBookBy(by id: Int) throws -> Book? {
        return try databaseManager.userDataQueue.read { db in
            let request = DatabaseBook
                .filter(id: Int64(id))
                .including(all: DatabaseBook.chapters)
                .asRequest(of: FetchedBookInfo.self)
            
            guard let fetchedBook = try FetchedBookInfo.fetchOne(db, request) else { throw BookRepositoryError.notFound(id: id) }
            
            return createBook(from: fetchedBook)
        }
    }
    
    /// Used by the BookSelector, this loads just enough information about the book for the user to choose.
    /// - Returns: A link to every book the user has in the database
    func getAllBookLinks() -> [BookLink] {
        do {
            return try databaseManager.userDataQueue.read { db in
                let rows = try Row.fetchCursor(db, sql: "SELECT id, name, author, cover_image_url FROM books")
                
                var links = [BookLink]()
                
                // Loop through every row creating the book links which will be returned
                while let row = try rows.next() {
                    links.append(BookLink(
                        bookId: row["id"] ?? 0,
                        title: row["name"] ?? "",
                        author: row["author"] ?? "",
                        coverImageURL: row["cover_image_url"] ?? ""
                    ))
                }
                
                return links
            }
        } catch {
            print("Failed to create book links: \(error)")
            return [BookLink]()
        }
    }
    
    /// Removes a book from the database and deletes the associated cover image from the filesystem
    /// - Parameter id: Id of the book to remove
    func removeBook(by id: Int) throws {
        try databaseManager.userDataQueue.write { db in
            guard let bookToRemove = try DatabaseBook
                .filter(id: Int64(id))
                .including(all: DatabaseBook.chapters)
                .fetchOne(db)
            else { throw BookRepositoryError.notFound(id: id) }
            
            if let coverImage = bookToRemove.cover_image_url {
                try fileStore.deleteItem(fileName: coverImage)
            }
            
            try bookToRemove.delete(db)
        }
    }
    
    /// Change either the name or author of the book
    /// - Parameters:
    ///   - id: The ID of the book to update
    ///   - title: The new title for the book
    ///   - author: The new author for the book
    func updateBookInformation(by id: Int, title: String?, author: String?) throws {
        try databaseManager.userDataQueue.write { db in
            guard var bookToUpdate = try DatabaseBook
                .filter(id: Int64(id))
                .fetchOne(db)
            else { return }
            
            if let updatedTitle = title {
                bookToUpdate.name = updatedTitle
            }
            
            if let updatedAuthor = author {
                bookToUpdate.author = updatedAuthor
            }
            
            try bookToUpdate.update(db)
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
            id: Int(fetchBookInfo.book.id ?? 0),
            name: fetchBookInfo.book.name,
            author: fetchBookInfo.book.author,
            chapters: chapters,
            coverImageUrl: fetchBookInfo.book.cover_image_url,
            currentChapter: Int(fetchBookInfo.book.current_chapter),
            dateLastOpened: fetchBookInfo.book.date_last_opened,
            dateCreated: fetchBookInfo.book.date_created)
    }
}
