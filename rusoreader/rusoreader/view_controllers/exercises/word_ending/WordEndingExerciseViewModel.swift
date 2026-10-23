import Foundation

final class WordEndingExerciseViewModel : ExerciseViewModel {
    let word: Word
    let wordForm: WordForm
    private let wordService: WordService
    
    init(word: Word, wordForm: WordForm, wordService: WordService) {
        self.word = word
        self.wordForm = wordForm
        self.wordService = wordService
    }
    
    /// Compares what the user submits to the actual answer. The ending of the word is weighted heavier than the stem of the word as that is what this exercise is focusing on
    /// - Parameter answer: A string value which is submited from a text field by the user
    /// - Returns: The grade the user will see and the associated score which will affect the spaced repetion algorithim
    func calculateResult(_ answer: String) -> ExerciseResult {
        let stems = wordService
            .getWordStems(of: word)
            .map { return $0.replacingOccurrences(of: "ё", with: "е") } // Remove the ё so users don't get it wrong for not using it
        let splitForms = wordForm.bare.split(separator: ",").map({ return $0.replacingOccurrences(of: "ё", with: "е") })
        
        var results = [ExerciseResult.Grade]()
        
        for stem in stems {
            for splitForm in splitForms {
                // first we will isolate the ending of the word as this is what this exercise is testing
                guard let endingIndex = splitForm.index(splitForm.startIndex, offsetBy: stem.count, limitedBy: splitForm.endIndex) else {
                    //return ExerciseResult(word: word, grade: .error, score: 0)
                    results.append(.error)
                    continue
                }
                let ending = splitForm[endingIndex..<splitForm.endIndex]
                
                if !answer.hasSuffix(ending) {
                    //return ExerciseResult(word: word, grade: .incorrect, score: 1)
                    results.append(.incorrect)
                    continue
                }
                
                // now we will check the stem, in this exercise its not as important so we can be a letter or two off depending on word length
                let checkableStem = String(answer[answer.startIndex..<answer.index(answer.endIndex, offsetBy: -ending.count)])
                results.append(wordService.gradeWord(userAnswer: checkableStem, actualAnswer: stem))
            }
        }

        // check the results array to see if we succeded or failed in the exercise
        // this is in a particular order or operations, we first must check if there are any correct results, then move down.
        if results.contains(.correct) {
            return ExerciseResult(word: word, grade: .correct, score: -1)
        } else if results.contains(.almost) {
            return ExerciseResult(word: word, grade: .almost, score: -0.5)
        } else if results.contains(.incorrect) {
            return ExerciseResult(word: word, grade: .incorrect, score: 1)
        } else {
            return ExerciseResult(word: word, grade: .error, score: 0)
        }
    }
    
    func cleanAnswerInput(_ answer: String) -> String {
        return answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var accentedBaseFormText: String {
        return wordService.addStress(to: word.accented)
    }
    
    var accentedWordFormText: String {
        return wordService.addStress(to: wordForm.accented)
    }

    var formText: String {
        return wordForm.formText
    }
    
    var wordFormBare: String {
        return wordForm.bare
    }
}
