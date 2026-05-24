import UIKit

class ReaderViewController: UIViewController, ReaderViewDelegate, TableOfContentsDelegate {
    let book: Book
    let wordRepo: WordRepository
    lazy var readerView = ReaderView()
    var selectionRange: SelectionRange?
    var lastOffsetY: CGFloat = 0.0
    var currentChapter: Int
    
    init(book: Book, wordRepo: WordRepository) {
        self.book = book
        self.wordRepo = wordRepo
        self.currentChapter = book.currentChapter
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "list.bullet"),
            style: .plain,
            target: self,
            action: #selector(openTableOfContents)
        )
        
        NSLayoutConstraint.activate([
            readerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            readerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            readerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            readerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8)
        ])
    }
    
    /// Takes a gesture location and uses it to find the tapped word and ultimately select the bounds of the entire sentence. Once this is finished word will be searched in the repository and then the WordDetailsView modal will pop up onto the screen.
    /// - Parameter location: The location on the screen where the user tapped, will be used to select the word.
    func didClickText(at location: CGPoint) {
        // We will update the layout just in case we get a chapter that is huge, which may cause a performance issue
        // only update this if there has been any scroll detected
        if (readerView.contentOffset.y != lastOffsetY) {
            let updatedY = readerView.bounds.minY + readerView.contentOffset.y + readerView.textContainerInset.top
            let updatedBounds = CGRect(x: readerView.bounds.minX, y: updatedY, width: readerView.bounds.width, height: readerView.bounds.height)
            let glyphRange = readerView.layoutManager.glyphRange(forBoundingRect: updatedBounds, in: readerView.textContainer)
            
            readerView.layoutManager.ensureLayout(forGlyphRange: glyphRange)
        }
        
        if let currentSelectedRange = selectionRange { // If there already something highlighted, just clear that out
            readerView.textStorage.addAttribute(.foregroundColor, value: UIColor.label, range: currentSelectedRange.wordRange)
            readerView.textStorage.removeAttribute(.underlineStyle, range: currentSelectedRange.sentenceRange)
            selectionRange = nil
        }
        // Get the users gesture input location, then the text view's layout manager can convert that cgrect to a character index. We will use that character index to handle the selection range. Once the selection range has been set we will highlight the word and underline the rest of the sentence.
        let layoutManager = readerView.layoutManager
        
        var location = location
        location.x -= readerView.textContainerInset.left
        location.y -= readerView.textContainerInset.top
        let charIndex = layoutManager.characterIndex(for: location, in: readerView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        // We are going to get the glyph range and bounding rect so we can check to see if the user actually tapped on a word or not
        let glyphRange = layoutManager.glyphRange(forCharacterRange: NSRange(location: charIndex, length: 1), actualCharacterRange: nil)
        let glyphBoundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: readerView.textContainer)
        
        // Check to see if the user tapped on a word or not, if the location of the tap is within the glyph range we can be sure the user actually tapped on something, which then we will proceed with pulling up the word details view
        if (location.x >= glyphBoundingRect.minX && location.x <= glyphBoundingRect.maxX) && (location.y >= glyphBoundingRect.minY && location.y <= glyphBoundingRect.maxY) {
            selectionRange = SelectionRange(text: book.chapters[currentChapter].text, characterIndex: charIndex)
            guard let currentRange = selectionRange else { return }
            
            if let wordRange = Range(currentRange.wordRange, in: book.chapters[currentChapter].text) {
                readerView.textStorage.addAttribute(.foregroundColor, value: UIColor.red, range: currentRange.wordRange)
                readerView.textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: currentRange.sentenceRange)
                readerView.textStorage.addAttribute(.underlineColor, value: UIColor.red, range: currentRange.sentenceRange)
                
                let highlightedWord = String(book.chapters[currentChapter].text[wordRange])
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
    
    /// A simple modal sheet for the table of contents
    @objc private func openTableOfContents() {
        let tableOfContents = TableOfContentsController(chapters: book.chapters)
        tableOfContents.modalPresentationStyle = .pageSheet
        tableOfContents.delegate = self
        self.present(tableOfContents, animated: true)
    }
    
    /// Set the reader view's text with the selected chapter's text, this will also be a point to reset any possible values the reader view has accumluated
    /// - Parameter index: Index of the chapter the user is trying to open
    func chapterTitleClicked(at index: Int) {
        if book.chapters.count > index {
            readerView.loadText(text: book.chapters[index].text)
            selectionRange = nil
            lastOffsetY = 0
            currentChapter = index
        }
    }
}
