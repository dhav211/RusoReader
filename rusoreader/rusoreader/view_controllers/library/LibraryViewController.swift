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
                try launcherDelegate?.onBookTapped(id: books[indexPath.row].id)
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
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                // ...
            }
            return UIMenu(children: [edit, delete])
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 144
    }
}
