import Foundation

final class LibraryViewModel {
    private let bookService: BookService
    var currentOpenedBook: LibraryBook? = nil
    
    init(bookService: BookService) {
        self.bookService = bookService
    }
    
    var isBookOpen: Bool {
        if currentOpenedBook != nil {
            return true
        } else {
            return false
        }
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
    
    func getUpdatedCurrentOpenedBook() -> LibraryBook? {
        guard let currentOpenedBook else { return nil }
        guard let book = bookService.getBook(by: currentOpenedBook.id) else { return nil }
        
        return LibraryBook(
            id: book.id,
            title: book.name,
            author: book.author,
            sortDate: Date.now,
            currentChapter: book.currentChapter,
            numberOfChapters: book.numberOfChapters,
            coverImageUrl: book.coverImageUrl
        )
    }
    
    /// Updates the library's data source, by adding the currently opened book to the top of the list and updating its chapter progress
    /// - Parameter books: The library's data source
    /// - Returns: The updated and sorted version of the library's data source
    func updateBooks(_ books: [LibraryBook]) -> [LibraryBook] {
        guard let bookToUpdate = currentOpenedBook else { return books }
        guard let book = bookService.getBook(by: bookToUpdate.id) else { return books }
        var updatedBooks = books
        if let openedBookIndex = updatedBooks.firstIndex(where: { $0.id == bookToUpdate.id}) {
            let updatedBook =  LibraryBook(
                id: book.id,
                title: book.name,
                author: book.author,
                sortDate: Date.now,
                currentChapter: book.currentChapter,
                numberOfChapters: book.numberOfChapters,
                coverImageUrl: book.coverImageUrl
            )

            // replace the book that will be closed with the book that has updated chapter and sort date, finally sort the books by the sort date
            updatedBooks[openedBookIndex] = updatedBook
            updatedBooks.sort(by: { $0.sortDate > $1.sortDate })
        }
        
        // Set the opened book to nil just in case there is any reload data hijinx later
        currentOpenedBook = nil

        return updatedBooks
    }
    
    func openBook(_ libraryBook: LibraryBook) {
        currentOpenedBook = libraryBook
    }
}
