import Foundation

/// A view model that manages the presentation and logic for flashcard-based vocabulary exercises.
///
/// This view model provides formatted word data, including stress marks and translations,
/// and calculates exercise results based on whether the user indicates they know the word.
/// It works with both individual words and example sentences to provide context for learning.
class FlashcardExerciseViewModel: ExerciseViewModel {
    let word: Word
    private let sentence: String
    private let wordService: WordService
    private let sentenceService: SentenceService
    
    init(word: Word, sentence: String, wordService: WordService, sentenceService: SentenceService) {
        self.word = word
        self.sentence = sentence
        self.wordService = wordService
        self.sentenceService = sentenceService
    }
    
    func getWordText() -> String {
        return wordService.addStress(to: word.accented)
    }
    
    func getSentence() -> String {
        return sentenceService.addStress(sentence: sentence)
    }
    
    func getTranslations() -> [String] {
        return word.translations
    }
    
    func getRangeOfBoldedText(_ sentence: String) -> NSRange? {
        return sentenceService.getRangeWithStress(of: word, in: sentence)
    }
    
    /// Calculates the user's score based on wether they know the word or not, their knowledge of the word is based on a bool
    /// - Parameter doesUserKnow: A bool representing wether they know the word or not, true meaning yes they know the word
    /// - Returns: An exercise result which holds the score that affects the words score and enum value representing if the exercise was a pass or fail, or somewhere in between
    func calculateResult(doesUserKnow: Bool) -> ExerciseResult {
        if doesUserKnow {
            return ExerciseResult(word: word, grade: .correct, score: 0)
        } else {
            return ExerciseResult(word: word, grade: .incorrect, score: 0.5)
        }
    }
}
