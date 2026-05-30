import UIKit

extension HomePageController: BookSelectorDelegate {
    func didTapBook(id: Int) {
        if !isOnHomePage {
            return
        }
        
        do {
            if let book = try bookRepo.findBookBy(by: id) {
                isOnHomePage = false
                navigationController?.pushViewController(ReaderViewController(book: book, wordRepo: WordRepository(databaseManager: dbManager), onClose: { self.isOnHomePage = true }), animated: true)
            }
        } catch {
            print(error)
            // TODO display a UIAlert message letting the user know the book cannot be opened
        }
    }
    
    func didLongPressBook(id: Int) {
        if !isOnHomePage {
            return
        }
        
        do {
            if let book = try bookRepo.findBookBy(by: id) {
                isOnHomePage = false
                let editBookMenu = EditBookViewController(bookTitle: book.name, bookAuthor: book.author, bookId: id)
                editBookMenu.modalPresentationStyle = .pageSheet
                editBookMenu.delegate = self
                let editBookNavigationController = UINavigationController(rootViewController: editBookMenu)
                present(editBookNavigationController, animated: true)
            }
        } catch {
            print(error)
        }
    }
}
