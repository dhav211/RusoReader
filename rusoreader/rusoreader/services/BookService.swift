import Foundation

enum BookServiceError: Error {
    case failedToStartAccessingSecurityScopedResource
}

class BookService {
    private let bookRepo: BookRepository
    
    init(bookRepo: BookRepository) {
        self.bookRepo = bookRepo
    }
    
    /// Extracts the data from a book object, currently supports epub
    /// - Parameter url: The url on the device to the book
    /// - Returns: If successful it will return a parsed book, if an error as occured then a nil will be returned.
    func parseBook(from url: URL) throws -> Book {
        if url.startAccessingSecurityScopedResource() {
            defer { url.stopAccessingSecurityScopedResource() }
            
            let epubParser = EpubParser()
            
            let parsedBook = try epubParser.parse(from: url)
            return try bookRepo.saveBook(parsedBook: parsedBook)
        } else {
            throw BookServiceError.failedToStartAccessingSecurityScopedResource
        }
    }
    
    func getBook(by id: Int) -> Book? {
        return bookRepo.findBookBy(by: id)
    }
    
    func getAllBooks() -> [Book] {
        return bookRepo.getAllBooks()
    }
    
    func getLastReadBook() -> Book? {
        return bookRepo.getLastReadBook()
    }
    
    func removeBook(by id: Int) throws {
        try bookRepo.removeBook(by: id)
    }

    func update(book: Book) throws {
        try bookRepo.updateBookInformation(book: book)
    }
    
    func getTableOfContentIndices(for book: Book) -> [TableOfContentIndex] {
        do {
            return try bookRepo.fetchTableOfContentIndices(by: book.id)
        } catch {
            print("Failed to fetch table of contents for \(book.name): \(error)")
            return [TableOfContentIndex]()
        }
    }
    
    func getChapter(from book: Book, at index: Int) -> Chapter? {
        do {
            return try bookRepo.fetchChapter(from: book.id, at: index)
        } catch {
            print("Couldn't get chapter \(index) from the \(book.name): \(error)")
            return nil
        }
    }
    
    func updateCurrentChapter(for book: Book, to index: Int) {
        do {
            try bookRepo.updateCurrentChapter(by: book.id, chapter: index)
        } catch {
            print("Couldn't update the chapter to \(index) for \(book.name)")
        }
    }
    
    func updateProgressOnCurrentChapter(from book: Book, to updatedProgress: Int) {
        bookRepo.updateChapterProgress(from: book.id, at: book.currentChapter, to: updatedProgress)
    }
    
    func getProgressOnCurrentChapter(from book: Book) -> Int {
        return bookRepo.fetchCurrentChaptersProgress(from: book.id, at: book.currentChapter)
    }
    
    func updateLastOpenedDate(for book: Book) {
        bookRepo.updateLastOpenedDate(for: book.id)
    }
}
