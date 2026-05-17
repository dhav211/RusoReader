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
            if url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                let epubParser = EpubParser()
                if let parsedBook = epubParser.parse(from: url), let book = bookRepo.saveBook(parsedBook: parsedBook) {
                    print(book.name)
                }
            }
        }
    }
}
