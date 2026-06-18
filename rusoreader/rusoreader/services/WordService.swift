class WordService {
    private let wordRepo: WordRepository
    
    init(wordRepo: WordRepository) {
        self.wordRepo = wordRepo
    }
    
    /// Find any word objects from a word form, for example the word form собаки would return the base form of собака
    /// - Parameter wordForm: A declined or conjungated form a word
    /// - Returns: The base form of a word, may return multiples as word forms can have multiple base forms
    func findMatches(from wordForm: String) -> [Word] {
        let ids = wordRepo.findWordIDs(by: wordForm)
        return wordRepo.findMatches(by: ids)
    }
    
    /// Finds the base form of an adjective by removing its suffix.
    /// - Parameters:
    ///   - adjective: The adjective to find the base form for, as a `String`.
    ///- Returns:A string representing the base form of the adjective. If the input is invalid (i.e., not a valid Russian adjective), an empty string is returned.
    func findAdjectiveBase(for adjective: String) -> String {
        let endingStemLetter = adjective[adjective.index(adjective.startIndex, offsetBy: adjective.count - 2)]
        let baseEndingIndex = isVowel(letter: endingStemLetter)
            ? adjective.index(adjective.startIndex, offsetBy: adjective.count - 2)
            : adjective.index(adjective.startIndex, offsetBy: adjective.count - 3)
        let base = adjective[adjective.startIndex..<baseEndingIndex]
        return String(base)
    }
    
    /// Checks whether a given letter is a vowel in Russian language.
    /// - Parameters:
    ///   - letter: The letter to check, as a `Character`.
    ///- Returns: A boolean value indicating whether the given letter is a vowel (`true`) or not (`false`).
    func isVowel(letter: Character) -> Bool {
        switch letter.lowercased() {
        case "а","э","ы","о","у","и","я","е","ё","ю":
            return true
        default:
            return false
        }
    }
    
    func addStress(to word: String) -> String {
        // If for some reason the word has more than one accent mark, it's an error, just return the string without stresses
        var numberOfAccents = 0
        for character in word {
            if character == "'" {
                numberOfAccents += 1
            }
        }
        if numberOfAccents > 1 {
            return word.replacingOccurrences(of: "'", with: "")
        }
        
        // When no stress mark is in word just return the word, it's probably a single vowel word
        guard let accentIndex = word.firstIndex(of: "'") else { return word }
        let characterToAccentIndex = word.index(before: accentIndex)
                
        // Another incredibly rare issue, but if we have a stressed constan
        if !isVowel(letter: word[characterToAccentIndex]) {
            guard let updatedAccentIndex = word.firstIndex(of: "'") else { return word }
            return word.replacingCharacters(in: updatedAccentIndex...updatedAccentIndex, with: "")
        }
        
        // here we just find the index of the of the matching character in the vowel index and then repeat with the accented vowel
        let vowels = "аеиоуыэюя"
        let accentedVowels = ["а́","е́","и́","о́","у́","ы́","э́","ю́","я́"]
        guard let vowelIndex = vowels.firstIndex(of: word[characterToAccentIndex]) else { return word }
        let intIndex = vowels.distance(from: vowels.startIndex, to: vowelIndex)

        // now finally we can replace the character at the original index with the character from the accented vowels index
        var wordWithStressMark = word.replacingCharacters(in: characterToAccentIndex...characterToAccentIndex, with: accentedVowels[intIndex])
        
        // remove the stress mark form the word and return it for it to be displayed on screen
        guard let updatedAccentIndex = wordWithStressMark.firstIndex(of: "'") else { return word }
        wordWithStressMark.remove(at: updatedAccentIndex)
        
        return wordWithStressMark
    }
}
