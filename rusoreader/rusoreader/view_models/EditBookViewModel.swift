final class EditBookViewModel {
    private let book: Book
    private let bookService: BookService

    init(book: Book, bookService: BookService) {
        self.book = book
        self.bookService = bookService
    }
    
    func deleteBook() throws {
        try bookService.removeBook(book: book)
    }
    
    func updateBook(author: String, title: String) throws {
        var bookToUpdate = book
        bookToUpdate.author = author
        bookToUpdate.name = title
        try bookService.update(book: bookToUpdate)
    }
    
    func getTitle() -> String {
        return book.name
    }
    
    func getAuthor() -> String {
        return book.author
    }
}
