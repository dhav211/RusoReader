import UIKit

class ReaderViewController: UITableViewController, TableOfContentsDelegate, ReaderViewSettingsDelegate {
    private var selections = [Int:Set<SelectionRange>]()
    private var currentSelections = Set<CurrentSelectionRange>()
    private var shouldScroll: Bool = true
    private let viewModel: ReaderViewModel
    
    init(viewModel: ReaderViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        // The user defaults can hold the default text size, this will return 0 if it's never been saved
        var textSize = Float(UserDefaults.standard.float(forKey: "textSize"))

        // A text size has never been saved so we will save a default text size of 16 right out of the gate
        if textSize == 0 {
            UserDefaults.standard.set(16, forKey: "textSize")
            textSize = 16
        }
        
        viewModel.setTextSize(to: textSize)
        
        do {
            try viewModel.setChapter(to: viewModel.currentChapter)
        } catch {
            // TODO create a UI Alert controller for displaying error messages, then on confirm it should dismiss this controller
            print(error.localizedDescription)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        viewModel.commitProgress()
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
    
        tableView.separatorStyle = .none
        tableView.register(ParagraphCellView.self, forCellReuseIdentifier: ParagraphCellView.reuseID)
        
        // There may be a chance there are no indices in the table of contents, if there are then show the button
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(systemName: "list.bullet"),
                style: .plain,
                target: self,
                action: #selector(openTableOfContents)
            ),
            viewModel.hasTableOfContents() ? UIBarButtonItem(
                image: UIImage(systemName: "gearshape"),
                style: .plain,
                target: self,
                action: #selector(openReaderSettings)
            ) : nil
        ].compactMap { $0 }
    }
    
    override func viewDidLayoutSubviews() {
        if shouldScroll && viewModel.paragraphCount() != 0 {
            shouldScroll = false
            tableView.scrollToRow(
                at: IndexPath(row: viewModel.currentProgress, section: 0), at: .top,
                animated: false
            )
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.paragraphCount()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ParagraphCellView.reuseID) as! ParagraphCellView
        if let paragraph = viewModel.getParagraph(at: indexPath.row) {
            cell.setText(with: paragraph)
            cell.setIndex(to: indexPath.row)
            cell.onTextClicked = { [weak self] paragraphView, location, index in
                self?.textClicked(in: paragraphView, at: location, from: index)
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {        
        if indexPath.row < viewModel.paragraphCount() - 1 {
            viewModel.updateProgress(to: indexPath.row + 1)
        }
    }
    
    /// Takes a gesture location and uses it to find the tapped word and ultimately select the bounds of the entire sentence. Once this is finished word will be searched in the repository and then the WordDetailsView modal will pop up onto the screen.
    /// - Parameter location: The location on the screen where the user tapped, will be used to select the word.
    func textClicked(in textView: ParagraphView, at location: CGPoint, from index: Int) {
        // Get the users gesture input location, then the text view's layout manager can convert that cgrect to a character index. We will use that character index to handle the selection range. Once the selection range has been set we will highlight the word and underline the rest of the sentence.
        let layoutManager = textView.layoutManager
        
        var location = location
        location.x -= textView.textContainerInset.left
        location.y -= textView.textContainerInset.top
        
        let charIndex = layoutManager.characterIndex(for: location, in: textView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
                
        // Check to see if the user tapped on a word or not, if the location of the tap is within the glyph range we can be sure the user actually tapped on something, which then we will proceed with pulling up the word details view
        if !isClickInGlyphRange(charIndex: charIndex, textContainer: textView.textContainer, location: location, layoutManager: layoutManager) {
            return
        }
        
        let selectionRange = SelectionRange(text: textView.text, characterIndex: charIndex)
        
        if let wordRange = Range(selectionRange.wordRange, in: textView.text) {
            //textView.highlightSelection(selectionRange: selectionRange)
            if let selectedParagraph = viewModel.getParagraph(at: index) {
                selectedParagraph.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: selectionRange.wordRange)
                selectedParagraph.addAttribute(.underlineColor, value: UIColor.blue, range: selectionRange.wordRange)
                textView.updateParagraphText(updatedParagraph: selectedParagraph)
                viewModel.setParagraph(at: index, with: selectedParagraph)
            }
            
            // If we have matches we can open the modal to show the details on the word
            if let wordDetailsViewModel = viewModel.buildWordDetailsViewModel(for: String(textView.text[wordRange])) {
                let wordDetails = WordDetailsView(viewModel: wordDetailsViewModel)
                wordDetails.modalPresentationStyle = .pageSheet
                self.present(wordDetails, animated: true)
            }
            
            // We are adding this selection so we can keep track of which words are highlighted
            currentSelections.insert(CurrentSelectionRange(index: index, selectionRange: selectionRange))
        }
    }
    
    /// A simple modal sheet for the table of contents
    @objc private func openTableOfContents() {
        viewModel.commitProgress()
        let tableOfContents = TableOfContentsController(indices: viewModel.tableOfContentIndices)
        tableOfContents.modalPresentationStyle = .pageSheet
        tableOfContents.delegate = self
        self.present(tableOfContents, animated: true)
    }

    /// A modal that only covers half the screen and will let the user change some basic settings
    @objc private func openReaderSettings() {
        let settings = ReaderViewSettingsController(currentTextSize: viewModel.currentTextSize)
        settings.delegate = self
        settings.modalPresentationStyle = .pageSheet
        settings.sheetPresentationController?.detents = [.medium()]
        self.present(settings, animated: true)
    }
    
    /// Set the reader view's text with the selected chapter's text, this will also be a point to reset any possible values the reader view has accumluated
    /// - Parameter index: Index of the chapter the user is trying to open
    func chapterTitleClicked(at index: Int) {
        do {
            try viewModel.setChapter(to: index)
            shouldScroll = true // We toggle this bool so when the viewDidLayoutSubviews is called the scroll view will scroll to the top for new chapter
            selections = [Int:Set<SelectionRange>]()
            currentSelections = Set<CurrentSelectionRange>()
            tableView.reloadData()
        } catch {
            // TODO create a UI Alert controller for displaying error messages, then on confirm it should dismiss this controller
            print(error.localizedDescription)
        }
    }
    
    private func isClickInGlyphRange(charIndex: Int, textContainer: NSTextContainer, location: CGPoint, layoutManager: NSLayoutManager) -> Bool {
        // We are going to get the glyph range and bounding rect so we can check to see if the user actually tapped on a word or not
        let glyphRange = layoutManager.glyphRange(forCharacterRange: NSRange(location: charIndex, length: 1), actualCharacterRange: nil)
        let glyphBoundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        
        if (location.x >= glyphBoundingRect.minX && location.x <= glyphBoundingRect.maxX) && (location.y >= glyphBoundingRect.minY && location.y <= glyphBoundingRect.maxY) {
            return true
        }
        
        return false
    }

    /// Changes the text size of the chapters paragraphs AttributedString. Once this is complete it will set the change as a default in the system to remember for next. Then will reload all the data to display the updated size
    /// - Parameter newSize:
    func updateTextSize(to newSize: Float) {
        if newSize > viewModel.currentTextSize || newSize < viewModel.currentTextSize {
            viewModel.setTextSize(to: newSize)
            UserDefaults.standard.set(newSize, forKey: "textSize")
            tableView.reloadData()
        }
    }
    
    private struct CurrentSelectionRange : Hashable {
        let index: Int
        let selectionRange: SelectionRange
    }
}
