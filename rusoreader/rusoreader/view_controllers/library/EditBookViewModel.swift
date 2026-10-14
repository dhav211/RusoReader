final class EditBookViewModel {
    private let book: Book
    private let bookService: BookService

    init(book: Book, bookService: BookService) {
        self.book = book
        self.bookService = bookService
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
    
    /// Compares the current and past state of a book's title and author to see if it's been edited
    /// - Parameters:
    ///   - authorFieldText: The current string value of the author text field
    ///   - titleFieldText: The current string value of the title text field
    /// - Returns: A boolean stating wether the book details have been edited
    func hasBookBeenEdited(authorFieldText: String, titleFieldText: String) -> Bool {
        if authorFieldText == book.author && titleFieldText == book.name {
            return false
        }
        
        return true
    }
}
