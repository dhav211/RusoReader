import UIKit

class ReaderViewController: UIViewController, ReaderViewDelegate {
    let book: Book
    let wordRepo: WordRepository
    lazy var readerView = ReaderView()
    var selectionRange: SelectionRange?
    var lastOffsetY: CGFloat = 0.0
    
    init(book: Book, wordRepo: WordRepository) {
        self.book = book
        self.wordRepo = wordRepo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        readerView.readerDelegate = self
        view.addSubview(readerView)
        
        readerView.loadText(text: book.chapters[book.currentChapter].text)
        
        //navigationItem.rightBarButtonItem = UIBarButtonItem(image: , style: <#T##UIBarButtonItem.Style#>, target: <#T##Any?#>, action: <#T##Selector?#>)
        
        NSLayoutConstraint.activate([
            readerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            readerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            readerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            readerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8)
        ])
    }
    
    @objc func didClickText(text: String, gesture: UITapGestureRecognizer) {
        // We will update the layout just in case we get a chapter that is huge, which may cause a performance issue
        // only update this if there has been any scroll detected
        if (readerView.contentOffset.y != lastOffsetY) {
            let updatedY = readerView.bounds.minY + readerView.contentOffset.y + readerView.textContainerInset.top
            let updatedBounds = CGRect(x: readerView.bounds.minX, y: updatedY, width: readerView.bounds.width, height: readerView.bounds.height)
            let glyphRange = readerView.layoutManager.glyphRange(forBoundingRect: updatedBounds, in: readerView.textContainer)
            
            readerView.layoutManager.ensureLayout(forGlyphRange: glyphRange)
        }
        
        if let currentSelectedRange = selectionRange {
            readerView.textStorage.addAttribute(.foregroundColor, value: UIColor.label, range: currentSelectedRange.wordRange)
            readerView.textStorage.removeAttribute(.underlineStyle, range: currentSelectedRange.sentenceRange)
            selectionRange = nil
        } else {
            // Get the users gesture input location, then the text view's layout manager can convert that cgrect to a character index. We will use that character index to handle the selection range. Once the selection range has been set we will highlight the word and underline the rest of the sentence.
            let layoutManager = readerView.layoutManager
            var location = gesture.location(in: readerView)
            location.x -= readerView.textContainerInset.left
            location.y -= readerView.textContainerInset.top
            let charIndex = layoutManager.characterIndex(for: location, in: readerView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
            selectionRange = SelectionRange(text: text, characterIndex: charIndex)
            guard let currentRange = selectionRange else { return }
            
            if let wordRange = Range(currentRange.wordRange, in: text) {
                readerView.textStorage.addAttribute(.foregroundColor, value: UIColor.red, range: currentRange.wordRange)
                readerView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: currentRange.sentenceRange)
                readerView.textStorage.addAttribute(.underlineColor, value: UIColor.red, range: currentRange.sentenceRange)
                
                let highlightedWord = String(text[wordRange])
                let ids = wordRepo.findWordIDs(by: highlightedWord)
                let matches = wordRepo.findMatches(by: ids)
                
                if !matches.isEmpty {
                    let wordDetails = WordDetailsView(words: matches)
                    wordDetails.modalPresentationStyle = .pageSheet
                    self.present(wordDetails, animated: true)
                }
            }
        }
    }
}
