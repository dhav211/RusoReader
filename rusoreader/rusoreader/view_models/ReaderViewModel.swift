import Foundation
import UIKit

struct ChapterLoadError: LocalizedError {
    var errorDescription: String?
    
    init(_ message: String) {
        self.errorDescription = message
    }
}

class ReaderViewModel {
    private let wordService: WordService
    private let bookService: BookService
    private let sentenceService: SentenceService
    private let book: Book
    private var chapterProgressToUpdate = 0
    private var textSize: CGFloat = 12
    private var paragraphs = [NSMutableAttributedString]()
    
    init(wordService: WordService, bookService: BookService, sentenceService: SentenceService, book: Book) {
        self.wordService = wordService
        self.bookService = bookService
        self.sentenceService = sentenceService
        self.book = book
    }
    
    func commitProgress() {
        bookService.updateProgressOnCurrentChapter(from: book, to: chapterProgressToUpdate)
    }

    func setChapter(to index: Int) throws {
        if let chapter = bookService.getChapter(from: book, at: index) {
            paragraphs = chapter.text.split(separator: "\n").map { paragraph in
                let paragraphText = NSMutableAttributedString(string: String(paragraph))
                paragraphText.addAttribute(.font, value: UIFont.systemFont(ofSize: textSize), range: NSRange(location: 0, length: paragraph.count))
                return paragraphText
            }
            
            bookService.updateCurrentChapter(for: book, to: index)
        } else {
            throw ChapterLoadError("Failed to load chapter at index \(index)")
        }
    }
    
    var currentChapter: Int {
        return book.currentChapter
    }
    
    var tableOfContentIndices: [TableOfContentIndex] {
        return bookService.getTableOfContentIndices(for: book)
    }
    
    func hasTableOfContents() -> Bool {
        return !tableOfContentIndices.isEmpty
    }
    
    var currentProgress: Int {
        return bookService.getProgressOnCurrentChapter(from: book)
    }
    
    func updateProgress(to value: Int) {
        chapterProgressToUpdate = value
    }

    var currentTextSize: Float {
        return Float(textSize)
    }

    /// Change the font size is every paragraphs AttributedString
    /// - Parameter newSize: The new size of the text
    func setTextSize(to newSize: Float) {
        textSize = CGFloat(newSize)
        for paragaph in paragraphs {
            paragaph.addAttribute(.font, value: UIFont.systemFont(ofSize: textSize), range: NSRange(location: 0, length: paragaph.string.count))
        }
    }

    func getParagraph(at index: Int) -> NSMutableAttributedString? {
        if paragraphs.count <= index {
            return nil
        }

        return paragraphs[index]
    }

    func setParagraph(at index: Int, with newParagraph: NSMutableAttributedString) {
        if paragraphs.count > index {
            paragraphs[index] = newParagraph
        }
    }

    func paragraphCount() -> Int {
        return paragraphs.count
    }
    
    func buildWordDetailsViewModel(for word: String) -> WordDetailsViewModel? {
        // TODO this shouldn't just get the first match but eventually this will load a page vew controller for the user to swipe through
        guard let matches = wordService.findMatches(from: word).first else { return nil }
        return WordDetailsViewModel(word: matches, wordService: wordService, sentenceService: sentenceService)
    }
}
