import Foundation

final class HomePageViewModel {
    private let bookService: BookService
    
    var lastOpenedBook: Book? {
        bookService.getLastReadBook()
    }
    
    init(bookService: BookService) {
        self.bookService = bookService
    }
}
