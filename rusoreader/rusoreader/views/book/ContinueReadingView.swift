import UIKit

protocol ContinueReadingDelegate : AnyObject {
    func onTapped(book: Book)
}

final class ContinueReadingView: UIView {
    private let book: Book?
    weak var delegate: ContinueReadingDelegate?

    init(book: Book?) {
        self.book = book
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        
        // The main stack is the total vertical stack, it contains the continue reading label along with the view containing all book information
        let mainStack = makeMainStack()
        addSubview(mainStack)
        
        mainStack.addArrangedSubview(makeContinueReadingLabel())
        
        // The tappable view contains everything about the book wrapped in a view which contains a gesture recongizer that launches the book in reader mode
        let tappableView = makeTappableView()
        mainStack.addArrangedSubview(tappableView)
        
        // This stack is split horizontally with cover image on the left and the information about the book and user's progress on the right
        let bookDetailsStack = makeBookDetailsStack()
        tappableView.addSubview(bookDetailsStack)
        bookDetailsStack.addArrangedSubview(CoverImageView(imageUrl: book?.coverImageUrl, width: 150))
        bookDetailsStack.addArrangedSubview(
            BookDetailsView(
                title: book?.name,
                author: book?.author,
                currentChapter: book?.currentChapter ?? 0,
                chapterCount: book?.numberOfChapters ?? 0
            )
        )
        
        setupConstraints(mainStack: mainStack, tappableView: tappableView, tappableStack: bookDetailsStack)
    }
    
    private func setupConstraints(mainStack: UIStackView, tappableView: UIView, tappableStack: UIStackView) {
        let margin: CGFloat = 16
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            tappableStack.topAnchor.constraint(equalTo: tappableView.topAnchor, constant: margin),
            tappableStack.bottomAnchor.constraint(equalTo: tappableView.bottomAnchor, constant: -margin),
            tappableStack.leadingAnchor.constraint(equalTo: tappableView.leadingAnchor, constant: margin),
            tappableStack.trailingAnchor.constraint(equalTo: tappableView.trailingAnchor, constant: -margin)
        ])
    }
    
    // MARK: - Factory Methods
    
    private func makeMainStack() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }
    
    private func makeContinueReadingLabel() -> UILabel {
        let label = UILabel()
        label.text = "Continue Reading"
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        return label
    }
    
    private func makeTappableView() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openBook)))
        return view
    }
    
    private func makeBookDetailsStack() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }
    
    // MARK: - Actions
    
    @objc private func openBook() {
        guard let book else { return }
        delegate?.onTapped(book: book)
    }
}
