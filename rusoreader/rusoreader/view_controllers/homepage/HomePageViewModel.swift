import Foundation

final class HomePageViewModel {
    private let bookService: BookService
    
    var lastOpenedBook: Book? {
        bookService.getLastReadBook()
    }
    
    init(bookService: BookService) {
        self.bookService = bookService
    }
    
    func parseBooks(from urls: [URL]) throws {
        for url in urls {
            try bookService.parseBook(from: url)
        }
    }
}
