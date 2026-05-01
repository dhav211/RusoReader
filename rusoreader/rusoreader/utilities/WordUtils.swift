class WordUtils {
    /// Finds the base form of an adjective by removing its suffix.
    ///
    /// This function assumes that adjectives in Russian language follow a specific pattern, where the base form ends with a consonant.
    /// - Parameters:
    ///   - adjective: The adjective to find the base form for, as a `String`.
    ///- Returns:A string representing the base form of the adjective. If the input is invalid (i.e., not a valid Russian adjective), an empty string is returned.
    static func findAdjectiveBase(for adjective: String) -> String {
        let endingStemLetter = adjective[adjective.index(adjective.startIndex, offsetBy: adjective.count - 2)]
        let baseEndingIndex = CyrillicUtils.isVowel(letter: endingStemLetter)
            ? adjective.index(adjective.startIndex, offsetBy: adjective.count - 2)
            : adjective.index(adjective.startIndex, offsetBy: adjective.count - 3)
        let base = adjective[adjective.startIndex..<baseEndingIndex]
        return String(base)
    }
}
