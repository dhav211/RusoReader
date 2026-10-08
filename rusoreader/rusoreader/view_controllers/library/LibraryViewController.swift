import UIKit

protocol LibraryLauncherDelegate: AnyObject {
    func onBookTapped(id: Int) throws
}

final class LibraryViewController: UITableViewController {
    let viewModel: LibraryViewModel
    var books: [LibraryBook]
    
    weak var launcherDelegate: LibraryLauncherDelegate?
    
    init(viewModel: LibraryViewModel) {
        self.viewModel = viewModel
        books = viewModel.getLibraryBooks()
        
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(LibraryBookTableViewCell.self, forCellReuseIdentifier: LibraryBookTableViewCell.reuseIdentifier)
        let addBookBarButton = viewModel.createAddBookBarButton()
        addBookBarButton.presentingViewController = self
        addBookBarButton.onBooksAdded = { [weak self] (book: Book) in
            self?.books.append(
                LibraryBook(
                    id: book.id,
                    title: book.name,
                    author: book.author,
                    sortDate: book.dateCreated,
                    currentChapter: book.currentChapter,
                    numberOfChapters: book.numberOfChapters,
                    coverImageUrl: book.coverImageUrl
                )
            )
            self?.books.sort(by: { $0.sortDate > $1.sortDate })
            self?.tableView.reloadData()
        }
        navigationItem.rightBarButtonItem = addBookBarButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Update the book data, this will move newly opened books to the top and change chapter progress when book is closed
        if viewModel.isBookOpen {
            books = viewModel.updateBooks(books)
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if books.count > indexPath.row {
            let book = books[indexPath.row]
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LibraryBookTableViewCell.reuseIdentifier) as? LibraryBookTableViewCell else { return UITableViewCell() }
            cell.configure(libraryBook: book)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row <= books.count {
            do {
                let currentLibraryBook = books[indexPath.row]
                try launcherDelegate?.onBookTapped(id: currentLibraryBook.id)
                viewModel.openBook(currentLibraryBook)
            } catch {
                print("The book couldn't be loaded")
                // TODO create a ui alert letting the user know the book can't be opened
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { [weak self] _ in
            let edit = UIAction(title: "Edit", image: UIImage(systemName: "pencil")) { _ in
                guard let bookId = self?.books[indexPath.row].id, let editBookController = self?.viewModel.createEditBookViewController(bookId: bookId) else { return }
                editBookController.onBookUpdated = {
                    guard let bookId = self?.books[indexPath.row].id else { return }
                    guard let updatedLibraryBook = self?.viewModel.getUpdatedLibraryBook(by: bookId) else { return }
                    self?.books[indexPath.row] = updatedLibraryBook
                    self?.tableView.reloadData()
                }
                editBookController.modalPresentationStyle = .pageSheet
                editBookController.sheetPresentationController?.detents = [.medium()]
                self?.present(editBookController, animated: true)
            }
            // Since deleting a book is a highly destructive action we should display a bit of warning just in case the user accidently clicks the delete button
            // This will pop up an alert menu where the user can make the confirmation
            let delete = UIAction(title: "Delete Book", image: UIImage(systemName: "trash")) { _ in
                let deleteAlert = UIAlertController(title: "Delete Book", message: "Are you sure you want to delete this book? This action cannot be undone.", preferredStyle: .alert)
                deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                    guard let bookId = self?.books[indexPath.row].id else { return }
                    do {
                        try self?.viewModel.deleteBook(bookId: bookId)
                        self?.books.remove(at: indexPath.row)
                        self?.tableView.reloadData()
                    } catch {
                        print(error)
                        // TODO display another UI Alert if possible saying there was an issue with deleting the book
                    }
                })
                self?.present(deleteAlert, animated: true)
            }
            return UIMenu(children: [edit, delete])
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 144
    }
}
