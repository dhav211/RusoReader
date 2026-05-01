import Foundation

/// Represents a range selection within a text string, defining word and sentence boundaries.
///
/// `SelectionRange` is used to determine the NSRange of a specific word and the NSRange of the full sentence
/// containing a given character index. It handles various delimiters including whitespace, punctuation,
/// and quotation marks to accurately identify text boundaries.
struct SelectionRange {
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
        var currentIndex = charIndex
        var startingIndex = 0
        var hasFoundStartOfWord = false
        
        // Loop backwards through the string looking for a punctuation, whitespace, or the zero index of the string
        while !hasFoundStartOfWord {
            if currentIndex == 0 {
                hasFoundStartOfWord = true
            } else {
                let character = text[text.index(text.startIndex, offsetBy: currentIndex)]
                if character.isPunctuation || character.isWhitespace {
                    hasFoundStartOfWord = true
                    currentIndex += 1 // We will need to increase the index by one because we don't want to start the search for the end of word with a white space
                    startingIndex = currentIndex
                } else { // If the character wasn't whitespace or punctuation, then lets go back one
                    currentIndex -= 1
                }
            }
        }
        
        var hasFoundEndOfWord = false
        var lengthCounter = 0 // this value will increment every loop so we know the length of the word
        // Now we can loop forward to find the end of word, this is done similarly to the last loop
        while !hasFoundEndOfWord {
            if currentIndex == text.count - 1 {
                hasFoundEndOfWord = true
            } else {
                let character = text[text.index(text.startIndex, offsetBy: currentIndex)]
                if (character.isPunctuation && character != "-") || character.isWhitespace {
                    hasFoundEndOfWord = true
                } else {
                    currentIndex += 1
                    lengthCounter += 1
                }
            }
        }
        
        return NSRange(location: startingIndex, length: lengthCounter)
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
        var startingLocation = 0
        var lengthCounter = 0
        var currentIndex = charIndex
        
        var hasFoundSentenceStart = false
        while !hasFoundSentenceStart {
            if currentIndex == 0 {
                hasFoundSentenceStart = true
            } else {
                if isSentenceTerminatingPunctuation(in: text, at: currentIndex) {
                    var i = 0
                    var hasReturned = false
                    // we will loop through the indices within the checkLength looking for a letter or a left point cheveron, that would indicate the sentence starting
                    while !hasReturned{
                        if currentIndex + i >= text.count - 1 {
                            hasReturned = true
                            break
                        }
                        let sentenceStartCheckerCharacter = text[text.index(text.startIndex, offsetBy: currentIndex + i)]
                        if sentenceStartCheckerCharacter.isLetter || sentenceStartCheckerCharacter == "«" || sentenceStartCheckerCharacter == "—" {
                            currentIndex += i
                            startingLocation = currentIndex
                            hasReturned = true
                            break
                        }
                        i += 1
                    }
                    
                    hasFoundSentenceStart = true
                } else {
                    currentIndex -= 1
                }
            }
        }
        
        var hasFoundSentenceEnd = false
        while !hasFoundSentenceEnd {
            if currentIndex == text.count - 1 {
                hasFoundSentenceEnd = true
            } else if isSentenceTerminatingPunctuation(in: text, at: currentIndex) {
                hasFoundSentenceEnd = true
            }
            lengthCounter += 1
            currentIndex += 1
        }
        
        return NSRange(location: startingLocation, length: lengthCounter)
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
