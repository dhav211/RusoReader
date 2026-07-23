import UIKit

protocol BookSelectorDelegate : AnyObject {
    func onOpenBookTapped(book: Book)
}

final class BookSelectorViewController: UIViewController, BookCardDelegate {
    private let viewModel: BookSelectorViewModel
    private let scrollView: UIScrollView
    private let bookCollection: UIStackView
    private var bookCards: [BookCard]
    private lazy var noBooksLabel: UILabel = {
        let label = UILabel()
        label.text = "You don't have any books!!"
        return label
    }()
    
    weak var selectorDelegate: BookSelectorDelegate?
    
    init(viewModel: BookSelectorViewModel) {
        self.viewModel = viewModel
        self.scrollView = UIScrollView()
        self.bookCollection = UIStackView()
        self.bookCards = [BookCard]()
        super.init(nibName: nil, bundle: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        bookCollection.translatesAutoresizingMaskIntoConstraints = false
        bookCollection.axis = .horizontal
        bookCollection.alignment = .center
        bookCollection.spacing = 16
        
        view.addSubview(scrollView)
        scrollView.addSubview(bookCollection)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bookCollection.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            bookCollection.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            bookCollection.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            bookCollection.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
        
        refresh()
    }
    
    func refresh() {
        if bookCards.isEmpty {
            noBooksLabel.removeFromSuperview()
        }
        
        for bookCard in bookCards {
            bookCard.removeFromSuperview()
        }
        
        bookCards.removeAll()
        
        let bookLinks = viewModel.getAllBookLinks()
        
        if bookLinks.isEmpty {
            bookCollection.addArrangedSubview(noBooksLabel)
        }
        
        for bookLink in bookLinks {
            addBook(bookLink: bookLink)
        }
    }
    
    /// Adds a visual representation of a book in the book selector
    /// - Parameter bookLink: A simplified model of a book
    private func addBook(bookLink: BookLink) {
        let bookCard = BookCard(bookLink: bookLink, size: CGSize(width: 300, height: 200))
        bookCard.delegate = self
        bookCollection.addArrangedSubview(bookCard)
        bookCards.append(bookCard)
    }
    
    // MARK: Delegate functions from the BookCard view
    
    func didClickReadBook(id: Int) {
        if let book = viewModel.getBook(by: id) {
            // Will call the app coordinator to launch the book in the reader
            selectorDelegate?.onOpenBookTapped(book: book)
        }
    }
    
    func didLongPressReadBook(id: Int) {
        if let book = viewModel.getBook(by: id) {
            // Slides up the edit book view menu so the queried book can be edited
            let editBookMenu = viewModel.createEditBookViewController(for: book)
            editBookMenu.modalPresentationStyle = .pageSheet
            editBookMenu.setOnClose() { [weak self] in
                self?.refresh()
            }
            let editBookNavigationController = UINavigationController(rootViewController: editBookMenu)
            present(editBookNavigationController, animated: true)
        }
    }
}
