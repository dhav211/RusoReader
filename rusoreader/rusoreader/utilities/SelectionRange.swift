import Foundation

struct SelectionRange {
    var wordRange: NSRange!
    var sentenceRange: NSRange!
    
    init(text: String, characterIndex: Int) {
        self.wordRange = getSelectedWordRange(from: text, at: characterIndex)
        self.sentenceRange = getSelectedSentenceRange(from: text, at: characterIndex)
    }
    
    
    /// Finds the range of the word from the given index
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
