import UIKit

protocol BookSelectorDelegate : AnyObject {
    func didTapBook(id: Int)
    func didLongPressBook(id: Int)
}

class BookSelector : UIScrollView, BookCardDelegate {
    let bookCollection: UIStackView
    var bookCards: [BookCard]
    weak var selectorDelegate: BookSelectorDelegate?
    
    init(bookRepo: BookRepository) {
        self.bookCollection = UIStackView()
        self.bookCards = [BookCard]()
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
        
        let bookLinks = bookRepo.getAllBookLinks()
        
        if bookLinks.isEmpty {
            let noBooksLabel = UILabel()
            noBooksLabel.text = "You don't have any books!!"
            bookCollection.addArrangedSubview(noBooksLabel)
        }
        
        for bookLink in bookLinks {
            addBook(bookLink: bookLink)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addBook(bookLink: BookLink) {
        let bookCard = BookCard(bookLink: bookLink, size: CGSize(width: 300, height: 200))
        bookCard.delegate = self
        bookCollection.addArrangedSubview(bookCard)
        bookCards.append(bookCard)
    }
    
    func removeBook(by id: Int) {
        guard let index = bookCards.firstIndex(where: { $0.bookId == id}) else { return }
        bookCards[index].removeFromSuperview()
        bookCards.remove(at: index)
    }
    
    func updateBook(by id: Int, author: String?, title: String?) {
        guard let card = bookCards.filter({ $0.bookId == id }).first else { return }
        
        if let updatedAuthor = author {
            card.updateAuthor(newAuthor: updatedAuthor)
        }
        
        if let updatedTitle = title {
            card.updateTitle(newTitle: updatedTitle)
        }
    }
    
    func didClickReadBook(readBookCard: BookCard) {
        selectorDelegate?.didTapBook(id: readBookCard.bookId)
    }
    
    func didLongPressReadBook(readBookCard: BookCard) {
        selectorDelegate?.didLongPressBook(id: readBookCard.bookId)
    }
    
}
