import Foundation

/// Represents a range selection within a text string, defining word and sentence boundaries.
///
/// `SelectionRange` is used to determine the NSRange of a specific word and the NSRange of the full sentence
/// containing a given character index. It handles various delimiters including whitespace, punctuation,
/// and quotation marks to accurately identify text boundaries.
struct SelectionRange : Hashable {
    var wordRange: NSRange!
    var sentenceRange: NSRange!
    
    init(text: String, characterIndex: Int) {
        self.wordRange = getSelectedWordRange(from: text, at: characterIndex)
        self.sentenceRange = getSelectedSentenceRange(from: text, at: characterIndex)
    }
    
    /// Determines and returns the NSRange of a word at a given character index.
    ///
    /// This function identifies the start and end of a word in a string by searching backwards for the first punctuation or whitespace, and forwards for the same delimiters.
    /// It handles special cases like hyphens and ensures the NSRange reflects the actual word boundaries.
    /// - Parameters:
    /// - text: The string to search within.
    /// - charIndex: The character index within the string to find the word.
    /// - Returns: An NSRange containing the location and length of the identified word.
    private func getSelectedWordRange(from text: String, at charIndex: Int) -> NSRange {
        // charIndex is a UTF-16 offset (e.g. from a text view's selectedRange).
        // Convert it to a String.Index instead of using offsetBy: directly.
        guard let charPosition = Range(NSRange(location: charIndex, length: 0), in: text)?.lowerBound else {
            return NSRange(location: charIndex, length: 0)
        }
    
        // Walk backwards by Character to find the start of the word
        var startIndex = charPosition
        while startIndex > text.startIndex {
            let previous = text.index(before: startIndex)
            if text[previous].isPunctuation || text[previous].isWhitespace {
                break
            }
            startIndex = previous
        }
    
        // Walk forwards by Character to find the end of the word
        var endIndex = charPosition
        while endIndex < text.endIndex {
            let character = text[endIndex]
            if (character.isPunctuation && character != "-") || character.isWhitespace {
                break
            }
            endIndex = text.index(after: endIndex)
        }
    
        return NSRange(startIndex..<endIndex, in: text)
    }
    
    /// Determines and returns the NSRange of the sentence containing a specific character.
    ///
    /// This function locates the beginning and end of a sentence within a string by searching backwards for sentence-ending punctuation and forwards for the sentence's conclusion.
    /// It handles special delimiters such as quotes or dashes to ensure accurate sentence boundaries.
    /// - Parameters:
    ///   - text: The string to search within.
    ///   - charIndex: The character index within the text to identify the target sentence.
    /// - Returns: An NSRange representing the full range (location and length) of the identified sentence.
    private func getSelectedSentenceRange(from text: String, at charIndex: Int) -> NSRange {
        guard let charPosition = Range(NSRange(location: charIndex, length: 0), in: text)?.lowerBound else {
            return NSRange(location: charIndex, length: 0)
        }
    
        // Walk backwards looking for sentence-terminating punctuation
        var searchIndex = charPosition
        var sentenceStart = text.startIndex
    
        while searchIndex > text.startIndex {
            let previous = text.index(before: searchIndex)
            if isSentenceTerminatingPunctuation(text[previous]) {
                // Found terminating punctuation of the PREVIOUS sentence.
                // Now scan forward from here looking for a letter, «, or — to find
                // where the new sentence actually starts.
                var scanIndex = searchIndex
                while scanIndex < text.endIndex {
                    let character = text[scanIndex]
                    if character.isLetter || character == "«" || character == "—" {
                        sentenceStart = scanIndex
                        break
                    }
                    scanIndex = text.index(after: scanIndex)
                }
                break
            }
            searchIndex = previous
        }
        // If we exited the loop via searchIndex == text.startIndex without finding
        // punctuation, sentenceStart correctly remains text.startIndex.
    
        // Walk forwards looking for the end of the sentence
        var endIndex = sentenceStart
        while endIndex < text.endIndex {
            let character = text[endIndex]
            endIndex = text.index(after: endIndex)
            if isSentenceTerminatingPunctuation(character) {
                break
            }
        }
    
        return NSRange(sentenceStart..<endIndex, in: text)
    }
    
    private func isSentenceTerminatingPunctuation(_ character: Character) -> Bool {
        character == "." || character == "!" || character == "?"
    }

    /// Determines whether a character at a specific index is considered sentence-terminating punctuation.
    ///
    /// This function checks if the character at the given index is standard sentence-ending punctuation
    /// (like ., ?, ! or a newline). It also verifies that a closing quotation mark does not immediately
    /// follow, ensuring it is the end of a sentence and not mid-sentence quote.
    /// - Parameters:
    ///     - text: The string containing the text to check.
    ///     - characterIndex: The integer index of the character within the string to check.
    /// - Returns: A Boolean value indicating whether the character marks the end of a sentence (true) or not (false).
    private func isSentenceTerminatingPunctuation(in text: String, at characterIndex: Int) -> Bool {
        let character = text[text.index(text.startIndex, offsetBy: characterIndex)]
        if character == "." || character == "?" || character == "!" || character.isNewline { // Not all punctuation ends a sentence, such as commas
            if characterIndex + 1 >= text.count - 1 { // lets make sure not to go out of bounds here, we are at the end of string, safe to assume that's the end of the sentence
                return true
            }
            // We need to check to see if we are not in a mid-sentence quotation. If we are the next character should be a right pointing cheveron
            // If it is a cheveron, we are not at the end of the sentence.
            let proceedingCharacter = text[text.index(text.startIndex, offsetBy: characterIndex + 1)]
            if proceedingCharacter == "»" {
                return false
            } else {
                return true
            }
        }
        return false
    }
}
