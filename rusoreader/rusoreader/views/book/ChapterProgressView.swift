import UIKit

final class ChapterProgressView: UIStackView {
    private let chapterLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setProgress(currentChapter: Int, chapterCount: Int) {
        chapterLabel.text = "\(currentChapter) of \(chapterCount)"
    }
    
    func clear() {
        chapterLabel.text?.removeAll()
    }
    
    private func setup() {
        axis = .horizontal
        spacing = 4
        
        let titleLabel = UILabel()
        titleLabel.text = "Chapter:"
        titleLabel.font = .preferredFont(forTextStyle: .subheadline)
        if let currentFont = titleLabel.font,
           let descriptor = currentFont.fontDescriptor.withSymbolicTraits(.traitBold) {
            titleLabel.font = UIFont(descriptor: descriptor, size: currentFont.pointSize)
        }
        
        chapterLabel.font = .preferredFont(forTextStyle: .subheadline)
        
        addArrangedSubview(titleLabel)
        addArrangedSubview(chapterLabel)
    }
}
