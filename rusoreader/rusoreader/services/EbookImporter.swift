import UIKit

final class EbookImporter : NSObject, UIDocumentPickerDelegate {
    let bookRepo : BookRepository
    let bookSelector : BookSelector
    
    init(bookRepo: BookRepository, bookSelector: BookSelector) {
        self.bookRepo = bookRepo
        self.bookSelector = bookSelector
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            if url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                let epubParser = EpubParser()
                do {
                    if let parsedBook = epubParser.parse(from: url) {
                        bookSelector.addBook(bookLink: try bookRepo.saveBook(parsedBook: parsedBook))
                    }
                } catch {
                    print("Error while adding book: \(error)")
                    // TODO add UIAlert here letting the user know there was an error adding the book
                }
            }
        }
    }
}
