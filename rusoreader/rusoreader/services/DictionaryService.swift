class DictionaryService {
    private let dictionaryRepo: DictionaryRepository
    private let wordService: WordService
    
    init(dictionaryRepo: DictionaryRepository, wordService: WordService) {
        self.dictionaryRepo = dictionaryRepo
        self.wordService = wordService
    }
    
    /// The total number of entries added to the dictionary
    var count: Int { dictionaryRepo.count }
    
    func getAllWords() -> [Word] {
        let wordIds = dictionaryRepo.getAll().map { entry in
            return entry.wordId
        }
        
        return wordService.findMatches(from: wordIds)
    }
    
    func updateWordScore(word: Word, by amount: Double) {
        dictionaryRepo.updateScore(for: word.id, by: amount)
    }
}
