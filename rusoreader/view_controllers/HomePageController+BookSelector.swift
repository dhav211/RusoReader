import UIKit

extension HomePageController: BookSelectorDelegate {
    func didTapBook(id: Int) {
        if let book = bookRepo.findBookBy(by: id) {
            print("lets open \(book.name) in the reader")
        }
    }
    
    func didLongPressBook(id: Int) {
        // we need to open a context menu, maybe a modal where we can edit the name of the book, author, or just remove it
    }
}
