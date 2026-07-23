final class BookSelectorViewModel {
    let bookService: BookService
    
    init(bookService: BookService) {
        self.bookService = bookService
    }
    
    func getAllBookLinks() -> [BookLink] {
        return bookService.getAllBookLinks()
    }
    
    func getBook(by id: Int) -> Book? {
        return bookService.getBook(by: id)
    }
    
    func createEditBookViewController(for book: Book) -> EditBookViewController {
        let editBook = EditBookViewController(viewModel: EditBookViewModel(book: book, bookService: bookService))
        return editBook
    }
}
