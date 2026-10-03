import UIKit

/// <#Description#>
final class LibraryBookTableViewCell: UITableViewCell {
    static let reuseIdentifier = "LibraryBook"
    
    private let coverImage: CoverImageView
    private let bookDetails: BookDetailsView
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.coverImage = CoverImageView()
        self.bookDetails = BookDetailsView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        coverImage.translatesAutoresizingMaskIntoConstraints = false
        bookDetails.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(coverImage)
        contentView.addSubview(bookDetails)
        
        NSLayoutConstraint.activate([
            coverImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            coverImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            bookDetails.leadingAnchor.constraint(equalTo: coverImage.trailingAnchor, constant: 16),
            bookDetails.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            bookDetails.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(libraryBook: LibraryBook) {
        bookDetails.configure(
            title: libraryBook.title,
            author: libraryBook.author,
            currentChapter: libraryBook.currentChapter,
            chapterCount: libraryBook.numberOfChapters
        )
        
        coverImage.configure(imageUrl: libraryBook.coverImageUrl, height: 120)
    }
}
