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
}
