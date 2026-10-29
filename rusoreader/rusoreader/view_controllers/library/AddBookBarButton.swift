import UIKit
import UniformTypeIdentifiers

final class AddBookBarButton: UIBarButtonItem, UIDocumentPickerDelegate {
    
    private let bookService: BookService
    weak var presentingViewController: UIViewController?
    var onBooksAdded: ((Book) -> Void)?
    
    init(bookService: BookService) {
        self.bookService = bookService
        super.init()
        title = "Add Book"
        target = self
        action = #selector(onTapped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        do {
            guard let url = urls.first else { return }
            let createdBook = try bookService.parseBook(from: url)
            onBooksAdded?(createdBook)
        } catch BookServiceError.bookAlreadyAdded(let bookTitle) {
            guard let presentingViewController else { return }
            let alert = UIAlertController.error(message: "\(bookTitle) is already added")
            presentingViewController.present(alert, animated: true)
        } catch {
            print("Failed to parse book: \(error)")
            guard let presentingViewController else { return }
            let alert = UIAlertController.error(message: "Failed to add book")
            presentingViewController.present(alert, animated: true)
        }
    }
    
        @objc private func onTapped() {
            let fb2Type = UTType("com.yourapp.fb2")
                ?? UTType(filenameExtension: "fb2")
                ?? .data
            
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.epub, fb2Type])
            picker.delegate = self
            picker.allowsMultipleSelection = false
            presentingViewController?.present(picker, animated: true)
        }
}
