import UIKit

extension HomePageController : UIDocumentPickerDelegate, AddBookButtonDelegate {
    func didClickAddBookButton(addBookButton: AddBookButton) {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.epub])
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            print(url)
        }
    }
}
