final class WordEndingMultipleChoiceFactory: ExerciseFactory {
    let word: Word
    var attempts: Int
    private let wordFormChoices: [String]
    private var correctWordForm: WordForm?
    private let wordService: WordService
    
    init(word: Word, wordService: WordService) {
        self.word = word
        self.attempts = 0
        self.wordService = wordService
        self.correctWordForm = RandomWordFormSelector.getRandomWordFormForExercise(from: word)

        if let correctForm = self.correctWordForm {
            self.wordFormChoices = Self.createMultipleChoiceData(correctForm.bare, self.word, wordService: wordService)
        } else {
            self.wordFormChoices = [String]()
        }
    }

    var hasWordFormChoices: Bool {
        return !wordFormChoices.isEmpty;
    }
    
    func createExercise() -> (any Exercise)? {
        guard let correctWordForm = correctWordForm else { return nil }
        if wordFormChoices.count <= 1 { return nil }
        return WordEndingMultipleChoiceView(
            viewModel: WordEndingMultipleChoiceExerciseViewModel(
                word: word, 
                correctWordForm: correctWordForm, 
                wordFormChoices: wordFormChoices, 
                wordService: wordService
            )
        )
    }

    /// Randomly choose two non-matching word forms from the word
    /// - Parameters:
    ///   - correctFormText: The already randomly chosen word text for this exercie
    ///   - word: The word we will be using to get the random word forms
    ///
    /// - Returns: A list of unique three word form strings, one is supplied and two are randomly chosen.
    private static func createMultipleChoiceData(_ correctFormText: String, _ word: Word, wordService: WordService) -> [String] {
        var selectedForms: Set = [correctFormText] // add the correct form in initially to compare against randomly chosen forms
        var attempts = 0 // attempt threshold to prevent infinite loop

        while selectedForms.count < 3 && attempts < 20 {
            attempts += 1
            
            // Choose a random word form and check if it's already added
            guard var randomForm = word.forms.shuffled().first?.bare else {
                break
            }

            if randomForm.contains(",") {
                randomForm = wordService.getRandomCommaSeperatedWordForm(randomForm)
            }

            if randomForm.isEmpty {
                continue
            }
            
            selectedForms.insert(randomForm)
        }

        return [String](selectedForms)
    }
}
