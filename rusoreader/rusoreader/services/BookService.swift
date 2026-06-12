import Foundation

class BookService {
    private let bookRepo: BookRepository
    
    init(bookRepo: BookRepository) {
        self.bookRepo = bookRepo
    }
    
    func getAllBookLinks() -> [BookLink] {
        return bookRepo.getAllBookLinks()
    }
    
    func parseBook(from url: URL) throws {
        if url.startAccessingSecurityScopedResource() {
            defer { url.stopAccessingSecurityScopedResource() }
            
            let epubParser = EpubParser()
            
            if let parsedBook = epubParser.parse(from: url) {
                try bookRepo.saveBook(parsedBook: parsedBook)
            }
        }
    }
    
    func getBook(by id: Int) -> Book? {
        do {
            return try bookRepo.findBookBy(by: id)
        } catch {
            print("Failed to find book by id \(id): \(error)")
            return nil
        }
    }
    
    func removeBook(book: Book) throws {
        try bookRepo.removeBook(by: book.id)
    }

    func update(book: Book) throws {
        try bookRepo.updateBookInformation(by: book.id, title: book.name, author: book.author)
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
}
