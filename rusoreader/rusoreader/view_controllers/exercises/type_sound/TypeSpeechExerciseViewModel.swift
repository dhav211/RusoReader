final class TypeSpeechExerciseViewModel: ExerciseViewModel {
    let word: Word
    private let wordForm: WordForm?
    private let wordService: WordService
    private var didUseHint: Bool = false
    
    init(word: Word, wordForm: WordForm?, wordService: WordService) {
        self.word = word
        self.wordForm = wordForm
        self.wordService = wordService
    }
    
    func calculateResult(_ answer: String) -> ExerciseResult {
        // if the didUseHint bool is true then the user should get a lower score
        return ExerciseResult(word: word, grade: .correct, score: 1)
    }
    
    func cleanAnswerInput(_ answer: String) -> String {
        return answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Creates a string with random letters displayed as blanks, the blanks are displayed as underscores
    var hint: String {
        didUseHint = true
        let answerWordForm = answerWordForm
        var hint = ""
        
        // hint counts will let the while loop know when to exit
        let maxLetterHints: Int = answerWordForm.bare.count / 2
        let minLetterHints: Int = max(answerWordForm.bare.count / 4, 1)
        var currentHints = 0
        
        repeat {
            currentHints = 0
            for i in 0..<answerWordForm.bare.count {
                let currentIndex = answerWordForm.bare.index(answerWordForm.bare.startIndex, offsetBy: i)
                
                if Bool.random() && currentHints < maxLetterHints {
                    currentHints += 1
                    
                    // if the last letter was an underscore then add a space
                    if let lastHint = hint.last, lastHint == "_" {
                        hint.append(" ")
                    }
                    hint.append(answerWordForm.bare[currentIndex])
                } else {
                    // unless it's the first letter, an underscore should always have a space before it
                    if i > 0 {
                        hint.append(" ")
                    }
                    hint.append("_")
                }
            }
        } while currentHints < minLetterHints
        
        return hint
    }
    
    /// An accented string that should help the speech synth pronounce the word correctly
    var spokenText: String {
        let stressedForm = if let wordForm {
            wordService.addStress(to: wordForm.accented)
        } else {
            wordService.addStress(to: word.accented)
        }
        
        if let firstForm = stressedForm.split(separator: ",").first {
            return String(firstForm)
        }
        
        return stressedForm
        
    }
    
    /// If the word form is nil then we will just create a new word form and assign the the word's values. This happens on adverbs and others
    var answerWordForm : WordForm {
        if let wordForm {
            wordForm
        } else {
            WordForm(bare: word.bare, accented: word.accented, form: .base)
        }
    }
}
