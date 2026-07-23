struct AppServices {
    let bookService: BookService
    let dictionaryService: DictionaryService
    let sentenceService: SentenceService
    let wordService: WordService
    
    init(bookService: BookService, dictionaryService: DictionaryService, sentenceService: SentenceService, wordService: WordService) {
        self.bookService = bookService
        self.dictionaryService = dictionaryService
        self.sentenceService = sentenceService
        self.wordService = wordService
    }
}
