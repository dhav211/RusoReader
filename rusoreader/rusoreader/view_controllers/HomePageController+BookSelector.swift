import UIKit

extension HomePageController: BookSelectorDelegate {
    func didTapBook(id: Int) {
        if let book = bookRepo.findBookBy(by: id) {
            navigationController?.pushViewController(ReaderViewController(book: book, wordRepo: WordRepository(databaseManager: dbManager)), animated: true)
        }
    }
    
    func didLongPressBook(id: Int) {
        // we need to open a context menu, maybe a modal where we can edit the name of the book, author, or just remove it
    }
}
