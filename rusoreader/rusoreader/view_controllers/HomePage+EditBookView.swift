import UIKit

extension HomePageController : EditBookViewDelegate {
    func didDeleteBook(id: Int) {
        do {
            if let book = bookService.getBook(by: id) {
                try bookService.removeBook(book: book)
            }
            dismiss(animated: true)
            bookSelector.refresh()
        } catch {
            
            // TODO display ui alert saying there was an issue deleting the book
            print(error)
        }
    }
    
    func didSave(id: Int, author: String?, title: String?) {
        do {
            if var book = bookService.getBook(by: id) {
                if let newAuthor = author {
                    book.author = newAuthor
                }
                if let newTitle = title {
                    book.author = newTitle
                }
                try bookService.update(book: book)
            }
            
            dismiss(animated: true)
            bookSelector.refresh()
        } catch {
            print()
            // Display a UI Alert Controller letting the user know the the update failed
        }
    }
    
    func didClose() {
        isOnHomePage = true
    }
}
