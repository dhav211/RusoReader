final class LibraryViewModel {
    private let bookService: BookService
    
    init(bookService: BookService) {
        self.bookService = bookService
    }
    
    func getLibraryBooks() -> [LibraryBook] {
        let allBooks = bookService.getAllBooks()
        return allBooks.compactMap { book in
            guard let sortDate = book.dateLastOpened == nil ? book.dateCreated : book.dateLastOpened else { return nil }
            return LibraryBook(
                id: book.id,
                title: book.name,
                author: book.author,
                sortDate: sortDate,
                currentChapter: book.currentChapter,
                numberOfChapters: book.numberOfChapters,
                coverImageUrl: book.coverImageUrl
            )
        }.sorted(by: { $0.sortDate > $1.sortDate })
    }
    
    func createEditBookViewController(bookId: Int) -> EditBookViewController? {
        guard let book = bookService.getBook(by: bookId) else { return nil }
        let editBookViewModel = EditBookViewModel(book: book, bookService: bookService)
        
        return EditBookViewController(viewModel: editBookViewModel)
    }
    
    func getUpdatedLibraryBook(by id: Int) -> LibraryBook? {
        guard let book = bookService.getBook(by: id) else { return nil }
        guard let sortDate = book.dateLastOpened == nil ? book.dateCreated : book.dateLastOpened else { return nil }
        
        return LibraryBook(
            id: book.id,
            title: book.name,
            author: book.author,
            sortDate: sortDate,
            currentChapter: book.currentChapter,
            numberOfChapters: book.numberOfChapters,
            coverImageUrl: book.coverImageUrl
        )
    }
}
