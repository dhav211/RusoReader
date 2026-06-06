import UIKit

class ReaderViewController: UITableViewController, ParagraphCellViewDelegate, TableOfContentsDelegate {
    private let book: Book
    private let wordRepo: WordRepository
    private var currentChapter: Int
    private var previousParagraph: PreviousParagraph?
    private var paragraphs = [String]()
    private var onClose : (() -> Void)?
    
    init(book: Book, wordRepo: WordRepository, onClose: @escaping (() -> Void)) {
        self.book = book
        self.wordRepo = wordRepo
        self.currentChapter = book.currentChapter
        self.onClose = onClose
        super.init(nibName: nil, bundle: nil)
        setParagraphs(from: book.chapters[currentChapter].text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        onClose?()
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
    
        tableView.separatorStyle = .none
        tableView.register(ParagraphCellView.self, forCellReuseIdentifier: "paragraph")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "list.bullet"),
            style: .plain,
            target: self,
            action: #selector(openTableOfContents)
        )
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paragraphs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ParagraphCellView.reuseID) as! ParagraphCellView
        cell.setText(with: paragraphs[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    /// Takes a gesture location and uses it to find the tapped word and ultimately select the bounds of the entire sentence. Once this is finished word will be searched in the repository and then the WordDetailsView modal will pop up onto the screen.
    /// - Parameter location: The location on the screen where the user tapped, will be used to select the word.
    func didClickText(in textView: ParagraphView, at location: CGPoint) {
        // If there already something highlighted, just clear that out
        if let previous = previousParagraph {
            previous.paragraph.removeHighlight(selectionRange: previous.selectionRange)
            previousParagraph = nil
        }
        // Get the users gesture input location, then the text view's layout manager can convert that cgrect to a character index. We will use that character index to handle the selection range. Once the selection range has been set we will highlight the word and underline the rest of the sentence.
        let layoutManager = textView.layoutManager
        
        var location = location
        location.x -= textView.textContainerInset.left
        location.y -= textView.textContainerInset.top
        let charIndex = layoutManager.characterIndex(for: location, in: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        // We are going to get the glyph range and bounding rect so we can check to see if the user actually tapped on a word or not
        let glyphRange = layoutManager.glyphRange(forCharacterRange: NSRange(location: charIndex, length: 1), actualCharacterRange: nil)
        let glyphBoundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textView.textContainer)
        
        // Check to see if the user tapped on a word or not, if the location of the tap is within the glyph range we can be sure the user actually tapped on something, which then we will proceed with pulling up the word details view
        if (location.x >= glyphBoundingRect.minX && location.x <= glyphBoundingRect.maxX) && (location.y >= glyphBoundingRect.minY && location.y <= glyphBoundingRect.maxY) {
            let selectionRange = SelectionRange(text: textView.text, characterIndex: charIndex)
            
            if let wordRange = Range(selectionRange.wordRange, in: textView.text) {
                textView.highlightSelection(selectionRange: selectionRange)
                
                let highlightedWord = String(textView.text[wordRange])
                let ids = wordRepo.findWordIDs(by: highlightedWord)
                let matches = wordRepo.findMatches(by: ids)
                
                // If we have matches we can open the modal to show the details on the word
                if !matches.isEmpty {
                    let wordDetails = WordDetailsView(words: matches)
                    wordDetails.modalPresentationStyle = .pageSheet
                    self.present(wordDetails, animated: true)
                }
            }
            
            // The passed in paragraph view and the selection range as the previous paragraph, so when this function runs again we can remove the highlights
            previousParagraph = PreviousParagraph(paragraph: textView, selectionRange: selectionRange)
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
            setParagraphs(from: book.chapters[index].text)
            tableView.reloadData()
            previousParagraph = nil
            currentChapter = index
        }
    }
    
    private func setParagraphs(from chapterText: String) {
        paragraphs = chapterText.split(separator: "\n").map { paragraph in
            return String(paragraph)
        }
    }
    
    /// Holds the data used to remove any highlighting from the text when the user clicks
    private struct PreviousParagraph {
        let paragraph: ParagraphView
        let selectionRange: SelectionRange
    }
}
