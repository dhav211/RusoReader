import UIKit
import UniformTypeIdentifiers

final class AddBookBarButton: UIBarButtonItem, UIDocumentPickerDelegate {
    
    private let bookService: BookService
    weak var presentingViewController: UIViewController?
    var loadBookTask : Task<Void, Never>?
    private var presentTask: Task<Void, Never>?
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
        var bookLoadingView: BookLoadingViewController? = nil
        
        // Although this will likely never be hit as books are parsed nearly instantly, but if the parsing is taking longer than half a second a modal will cover the screen letting the user know that the book is parsing. The user will have the opition to cancel the parsing.
        presentTask = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            bookLoadingView = BookLoadingViewController()
            bookLoadingView?.onCancelled = { self?.loadBookTask?.cancel() }
            bookLoadingView?.modalPresentationStyle = .overFullScreen

            guard let bookLoadingView else { return }
            self?.presentingViewController?.present(bookLoadingView, animated: true)
        }
        
        let onCancelBookLoadingView = { [weak self] in
            await MainActor.run {
                self?.presentTask?.cancel()
                bookLoadingView?.dismiss(animated: true)
            }
        }
        
        // Let the book parse in the back ground so it won't hang the UI
        loadBookTask = Task { [weak self] in
            do {
                guard let url = urls.first else { return }
                guard let createdBook = try await self?.bookService.parseBook(from: url), !Task.isCancelled else {
                    await onCancelBookLoadingView()
                    
                    return
                }
                self?.onBooksAdded?(createdBook)
            } catch BookServiceError.bookAlreadyAdded(let bookTitle) {
                guard let presentingViewController = self?.presentingViewController else { return }
                let alert = UIAlertController.error(message: "\(bookTitle) is already added")
                presentingViewController.present(alert, animated: true)
            } catch {
                print("Failed to parse book: \(error)")
                guard let presentingViewController = self?.presentingViewController else { return }
                let alert = UIAlertController.error(message: "Failed to add book")
                presentingViewController.present(alert, animated: true)
            }
            
            await onCancelBookLoadingView()
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
