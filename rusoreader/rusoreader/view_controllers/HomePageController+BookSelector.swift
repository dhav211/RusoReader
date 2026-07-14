import UIKit

extension HomePageController: BookSelectorDelegate {
    func didTapBook(id: Int) {
        if !isOnHomePage {
            return
        }
        
        if let book = bookService.getBook(by: id) {
            isOnHomePage = false
            let readerViewModel = ReaderViewModel(wordService: wordService, bookService: bookService, sentenceService: sentenceService, book: book)
            navigationController?.pushViewController(
                ReaderViewController(viewModel: readerViewModel),
                animated: true
            )
        }
    }
    
    func didLongPressBook(id: Int) {
        if !isOnHomePage {
            return
        }
        
        if let book = bookService.getBook(by: id) {
            isOnHomePage = false
            let editBookMenu = EditBookViewController(bookTitle: book.name, bookAuthor: book.author, bookId: id)
            editBookMenu.modalPresentationStyle = .pageSheet
            editBookMenu.delegate = self
            let editBookNavigationController = UINavigationController(rootViewController: editBookMenu)
            present(editBookNavigationController, animated: true)
        }
    }
}
