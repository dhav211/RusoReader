import UIKit

protocol BookSelectorDelegate : AnyObject {
    func didTapBook(id: Int)
    func didLongPressBook(id: Int)
}

class BookSelector : UIScrollView, BookCardDelegate {
    private let bookCollection: UIStackView
    private var bookCards: [BookCard]
    private let bookService: BookService
    private lazy var noBooksLabel: UILabel = {
        let label = UILabel()
        label.text = "You don't have any books!!"
        return label
    }()
    
    weak var selectorDelegate: BookSelectorDelegate?
    
    init(bookService: BookService) {
        self.bookCollection = UIStackView()
        self.bookCards = [BookCard]()
        self.bookService = bookService
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        bookCollection.translatesAutoresizingMaskIntoConstraints = false
        bookCollection.axis = .horizontal
        bookCollection.alignment = .center
        bookCollection.spacing = 16
        addSubview(bookCollection)
        
        NSLayoutConstraint.activate([
            bookCollection.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
            bookCollection.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
            bookCollection.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
            bookCollection.heightAnchor.constraint(equalTo: frameLayoutGuide.heightAnchor)
        ])
        
        refresh()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refresh() {
        if bookCards.isEmpty {
            noBooksLabel.removeFromSuperview()
        }
        
        for bookCard in bookCards {
            bookCard.removeFromSuperview()
        }
        
        bookCards.removeAll()
        
        let bookLinks = bookService.getAllBookLinks()
        
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
    
    func didClickReadBook(readBookCard: BookCard) {
        selectorDelegate?.didTapBook(id: readBookCard.bookId)
    }
    
    func didLongPressReadBook(readBookCard: BookCard) {
        selectorDelegate?.didLongPressBook(id: readBookCard.bookId)
    }
    
}
