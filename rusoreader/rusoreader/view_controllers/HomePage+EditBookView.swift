import UIKit

extension HomePageController : EditBookViewDelegate {
    func didDeleteBook(id: Int) {
        do {
            try bookRepo.removeBook(by: id)
            dismiss(animated: true)
            bookSelector.removeBook(by: id)
        } catch {
            print(error)
        }
    }
    
    func didSave(id: Int, author: String?, title: String?) {
        do {
            try bookRepo.updateBookInformation(by: id, title: title, author: author)
            dismiss(animated: true)
            bookSelector.updateBook(by: id, author: author, title: title)
        } catch {
            print()
            // Display a UI Alert Controller letting the user know the the update failed
        }
    }
    
    func didClose() {
        isOnHomePage = true
    }
}
