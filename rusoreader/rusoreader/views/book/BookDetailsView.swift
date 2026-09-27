import UIKit

/// Displays information about the book, values can be nil and then won't be displayed. If the chapterCount is 0 then that prevent the chapter progres text from being displayed. This will be used in the ContinueReadingView and also in the cells for the Library Table
final class BookDetailsView: UIStackView {
    private let title: String?
    private let author: String?
    private let currentChapter: Int
    private let chapterCount: Int
    
    init(title: String?, author: String?, currentChapter: Int, chapterCount: Int) {
        self.title = title
        self.author = author
        self.currentChapter = currentChapter
        self.chapterCount = chapterCount
        
        super.init(frame: .zero)
        
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        axis = .vertical
        alignment = .leading
        spacing = 4
        
        if let titleLabel = makeTitleLabel() { addArrangedSubview(titleLabel) }
        if let authorLabel = makeAuthorLabel() { addArrangedSubview(authorLabel) }
        if let chapterStack = makeChapterStack() { addArrangedSubview(chapterStack) }
    }

    
    private func makeTitleLabel() -> UILabel? {
        guard let title else { return nil }
        
        let label = UILabel()
        label.text = title
        label.numberOfLines = 0
        let baseFont = UIFont.preferredFont(forTextStyle: .body)
        if let boldDescriptor = baseFont.fontDescriptor.withSymbolicTraits(.traitBold) {
            label.font = UIFont(descriptor: boldDescriptor, size: 0)
        } else {
            label.font = baseFont
        }
        return label
    }
    
    private func makeAuthorLabel() -> UILabel? {
        guard let author else { return nil }
        
        let label = UILabel()
        label.text = author
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .subheadline)
        return label
    }
    
    private func makeChapterStack() -> UIStackView? {
        if chapterCount <= 0 { return nil } // If there aren't any chapters in the book then don't create this stack, or if somehow there is a massive error in the db and it's returning negative chapters
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        
        let titleLabel = UILabel()
        titleLabel.text = "Chapter:"
        titleLabel.font = .preferredFont(forTextStyle: .subheadline)
        if let currentFont = titleLabel.font,
           let descriptor = currentFont.fontDescriptor.withSymbolicTraits(.traitBold) {
            titleLabel.font = UIFont(descriptor: descriptor, size: currentFont.pointSize)
        }
        
        // Turn the two chapter ints into a readable label
        let chapterLabel = UILabel()
        chapterLabel.text = "\(currentChapter) of \(chapterCount)"
        chapterLabel.font = .preferredFont(forTextStyle: .subheadline)
        
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(chapterLabel)
        
        return stack
    }
}
