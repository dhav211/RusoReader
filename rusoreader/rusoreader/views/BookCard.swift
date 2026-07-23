import UIKit

protocol BookCardDelegate : AnyObject {
    func didClickReadBook(id: Int)
    func didLongPressReadBook(id: Int)
}

class BookCard : UIView {
    var author: String
    var title: String
    let coverImage: UIImage?
    let bookId: Int
    let size: CGSize
    lazy var authorLabel = UILabel()
    lazy var titleLabel = UILabel()
    
    weak var delegate: BookCardDelegate?
    
    init(bookLink: BookLink, size: CGSize) {
        self.author = bookLink.author
        self.title = bookLink.title
        
        // Pull the cover image from the file store
        self.coverImage = {
            do {
                let fileStore = FileStore()
                return UIImage(data: try fileStore.load(fileName: bookLink.coverImageURL))
            } catch {
                print("\(error)")
                return nil
            }
        }()
        self.bookId = bookLink.bookId
        self.size = size
        
        super.init(frame: .zero)
        self.buildBookCard()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildBookCard() {
        translatesAutoresizingMaskIntoConstraints = false

        // A single tap will open the reader view
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapRecognizer)
        
        // A long touch will open the the edit book modal
        let longTouchRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongTouch))
        addGestureRecognizer(longTouchRecognizer)
        
        // This will be removed at some point, but it simply sets a random color as the card background
        let colors = [UIColor.systemRed, UIColor.systemBlue, UIColor.systemYellow, UIColor.systemMint]
        backgroundColor = colors[Int.random(in: 0..<colors.count)]
        layer.cornerRadius = 10
        
        // The split stack will hold the cover image on the left and the book details on the right
        let splitStack = UIStackView()
        splitStack.axis = .horizontal
        splitStack.alignment = .center
        splitStack.spacing = 4.0
        splitStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(splitStack)
            
        // If there is a cover image for this book we will create a ImageView for it and set it's size to to fit in the left side, this sizing will scale with whatever we decide to change the book card size to
        if let image = coverImage {
            let coverImageView = UIImageView(image: image)
            NSLayoutConstraint.activate([
                coverImageView.widthAnchor.constraint(equalToConstant: size.width * 0.33),
                coverImageView.heightAnchor.constraint(equalToConstant: size.height - (size.height * 0.25)),
            ])

            coverImageView.contentMode = .scaleAspectFit
            coverImageView.clipsToBounds = true
            
            splitStack.addArrangedSubview(coverImageView)
        }
        
        // The information stack holds the book title and author
        let informationStack = UIStackView()
        informationStack.axis = .vertical
        informationStack.alignment = .leading
        informationStack.distribution = .equalSpacing
        informationStack.spacing = 4.0
        splitStack.spacing = 4.0
        splitStack.addArrangedSubview(informationStack)
        
        authorLabel.text = author
        authorLabel.numberOfLines = 3
        informationStack.addArrangedSubview(authorLabel)
        
        titleLabel.text = title
        titleLabel.numberOfLines = 3
        informationStack.addArrangedSubview(titleLabel)
        
        
        let padding = 12.0
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height),
            splitStack.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            splitStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
            splitStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            splitStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
        ])
    }
    
    /// Updates the title label
    /// - Parameter newTitle: The title change
    public func updateTitle(newTitle: String) {
        title = newTitle
        titleLabel.text = newTitle
    }
    
    /// Updates the author label
    /// - Parameter newAuthor: the author change
    public func updateAuthor(newAuthor: String) {
        author = newAuthor
        authorLabel.text = newAuthor
    }
    
    @objc func handleTap() {
        delegate?.didClickReadBook(id: bookId)
    }
    
    @objc func handleLongTouch() {
        delegate?.didLongPressReadBook(id: bookId)
    }
}
