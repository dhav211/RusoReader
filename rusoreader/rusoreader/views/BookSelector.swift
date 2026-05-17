import UIKit

protocol BookSelectorDelegate : AnyObject {
    func didTapBook(id: Int)
    func didLongPressBook(id: Int)
}

class BookSelector : UIScrollView, ReadBookCardDelegate {
    let bookCollection: UIStackView
    var bookCards: [ReadBookCard]
    weak var selectorDelegate: BookSelectorDelegate?
    
    init(bookRepo: BookRepository) {
        self.bookCollection = UIStackView()
        self.bookCards = [ReadBookCard]()
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
            let bookCard = ReadBookCard(bookLink: bookLink)
            bookCollection.addArrangedSubview(bookCard)
            bookCard.buildBookCard()
            bookCard.delegate = self
            bookCards.append(bookCard)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didClickReadBook(readBookCard: ReadBookCard) {
        selectorDelegate?.didTapBook(id: readBookCard.bookId)
    }
    
    func didLongPressReadBook(readBookCard: ReadBookCard) {
        selectorDelegate?.didLongPressBook(id: readBookCard.bookId)
    }
    
}
