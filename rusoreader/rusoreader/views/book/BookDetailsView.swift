import UIKit

/// Displays information about the book, values can be nil and then won't be displayed. If the chapterCount is 0 then that prevent the chapter progres text from being displayed. This will be used in the ContinueReadingView and also in the cells for the Library Table
final class BookDetailsView: UIStackView {
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let chapterProgress = ChapterProgressView()
    
    init() {
        super.init(frame: .zero)
        
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String?, author: String?, currentChapter: Int = 0, chapterCount: Int = 0) {
        if let title {
            titleLabel.text = title
        } else {
            titleLabel.text?.removeAll()
        }
        
        if let author {
            authorLabel.text = author
        } else {
            authorLabel.text?.removeAll()
        }
        
        if currentChapter > 0 && chapterCount > 0 {
            chapterProgress.setProgress(currentChapter: currentChapter, chapterCount: chapterCount)
        } else {
            chapterProgress.clear()
        }
    }
    
    private func setup() {
        axis = .vertical
        alignment = .leading
        spacing = 4
        
        titleLabel.numberOfLines = 0
        let baseFont = UIFont.preferredFont(forTextStyle: .body)
        if let boldDescriptor = baseFont.fontDescriptor.withSymbolicTraits(.traitBold) {
            titleLabel.font = UIFont(descriptor: boldDescriptor, size: 0)
        } else {
            titleLabel.font = baseFont
        }
        
        authorLabel.numberOfLines = 0
        authorLabel.font = .preferredFont(forTextStyle: .subheadline)
        
        addArrangedSubview(titleLabel)
        addArrangedSubview(authorLabel)
        addArrangedSubview(chapterProgress)
    }
}
