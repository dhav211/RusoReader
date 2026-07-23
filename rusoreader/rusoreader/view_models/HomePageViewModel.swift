import Foundation

final class HomePageViewModel {
    private let bookService: BookService
    
    init(bookService: BookService) {
        self.bookService = bookService
    }
    
    func createBookSelector() -> BookSelectorViewController {
        return BookSelectorViewController(viewModel: BookSelectorViewModel(bookService: bookService))
    }
    
    func parseBooks(from urls: [URL]) throws {
        for url in urls {
            try bookService.parseBook(from: url)
        }
    }
}
