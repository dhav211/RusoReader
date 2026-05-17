import UIKit

protocol ReadBookCardDelegate : AnyObject {
    func didClickReadBook(readBookCard: ReadBookCard)
    func didLongPressReadBook(readBookCard: ReadBookCard)
}

class ReadBookCard : UIView {
    let author: String
    let title: String
    let coverImage: UIImage?
    let bookId: Int
    
    weak var delegate: ReadBookCardDelegate?
    
    init(bookLink: BookLink) {
        self.author = bookLink.author
        self.title = bookLink.title
        self.coverImage = {
            do {
                if let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let coverImageURL = documents.appendingPathComponent(bookLink.coverImageURL)
                    let coverImageData = try Data(contentsOf: coverImageURL)
                    return UIImage(data: coverImageData)
                }
            } catch {
                print("\(error)")
            }
            return nil
        }()
        self.bookId = bookLink.bookId
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildBookCard() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapRecognizer)
        let longTouchRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongTouch))
        addGestureRecognizer(longTouchRecognizer)
        
        let colors = [UIColor.systemRed, UIColor.systemBlue, UIColor.systemYellow, UIColor.systemMint]
        backgroundColor = colors[Int.random(in: 0..<colors.count)]
        alpha = 0.7
        layer.cornerRadius = 10
        
        let splitStack = UIStackView()
        splitStack.axis = .horizontal
        splitStack.alignment = .center
        splitStack.spacing = 4.0
        
        translatesAutoresizingMaskIntoConstraints = false
        splitStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(splitStack)
        
        if let image = coverImage {
            let coverImageView = UIImageView(image: image)
            NSLayoutConstraint.activate([
                coverImageView.widthAnchor.constraint(equalToConstant: 100),
                coverImageView.heightAnchor.constraint(equalToConstant: 150),
            ])

            coverImageView.contentMode = .scaleAspectFit
            coverImageView.clipsToBounds = true
            
            splitStack.addArrangedSubview(coverImageView)
        }
        
        let informationStack = UIStackView()
        informationStack.axis = .vertical
        informationStack.alignment = .leading
        informationStack.distribution = .equalSpacing
        informationStack.spacing = 4.0
        splitStack.spacing = 4.0
        splitStack.addArrangedSubview(informationStack)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.numberOfLines = 3
        informationStack.addArrangedSubview(titleLabel)
        
        let authorLabel = UILabel()
        authorLabel.text = author
        authorLabel.numberOfLines = 3
        informationStack.addArrangedSubview(authorLabel)
        
        let padding = 12.0
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 300),
            heightAnchor.constraint(equalToConstant: 200),
            splitStack.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            splitStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
            splitStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            splitStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
        ])
    }
    
    @objc func handleTap() {
        delegate?.didClickReadBook(readBookCard: self)
    }
    
    @objc func handleLongTouch() {
        delegate?.didLongPressReadBook(readBookCard: self)
    }
}
