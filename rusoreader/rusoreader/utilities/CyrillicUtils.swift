class CyrillicUtils {
    /**
     * Checks whether a given letter is a vowel in Russian language.

    * This function considers only lowercase letters and returns `true` if the letter is one of the standard vowels in Russian language, and `false` otherwise.

    * - Parameters:
        - letter: The letter to check, as a `Character`.

    * - Returns:
      A boolean value indicating whether the given letter is a vowel (`true`) or not (`false`).
     */
    static func isVowel(letter: Character) -> Bool {
        switch letter.lowercased() {
        case "а","э","ы","о","у","и","я","е","ё","ю":
            return true
        default:
            return false
        }
    }
}
