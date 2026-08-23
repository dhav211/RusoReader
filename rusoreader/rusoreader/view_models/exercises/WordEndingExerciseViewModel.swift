import Foundation

final class WordEndingExerciseViewModel : ExerciseViewModel {
    let word: Word
    private let wordForm: WordForm
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
        // we will trim and lowercase the input so the user won't be dinged for accidently clicking space or capitializing a letter
        let checkable = answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let stem = wordService.getWordStem(of: word)
        
        // first we will isolate the ending of the word as this is what this exercise is testing
        guard let endingIndex = wordForm.bare.index(wordForm.bare.startIndex, offsetBy: stem.count, limitedBy: wordForm.bare.endIndex) else {
            return ExerciseResult(word: word, grade: .error, score: 0)
        }
        let ending = wordForm.bare[endingIndex..<wordForm.bare.endIndex]
        
        if !checkable.hasSuffix(ending) {
            return ExerciseResult(word: word, grade: .incorrect, score: 1)
        }
        
        // now we will check the stem, in this exercise its not as important so we can be a letter or two off depending on word length
        let checkableStem = String(checkable[checkable.startIndex..<checkable.index(checkable.endIndex, offsetBy: -ending.count)])
        let differenceTolerance = max(checkableStem.count / 10, 1)
        let difference = StringComparasion.compare(stem, checkableStem)
        
        // an exact match is considered correct with full points
        if difference == 0 {
            return ExerciseResult(word: word, grade: .correct, score: -1)
        // if it's within tolerance points are still rewarded but let the user know they weren't fully correct
        } else if difference > 0 && difference <= differenceTolerance {
            return ExerciseResult(word: word, grade: .almost, score: -0.5)
        // out of tolerance means the exercise was wrong, points will be affected and user must try again
        } else {
            return ExerciseResult(word: word, grade: .incorrect, score: 1)
        }
    }
    
    /// Finds the differences in the users answer with the actual answer
    /// - Parameter answer: The user's input from a text field
    /// - Returns: An array of ints which show which letters are different, this will be used to create an AttributedString with bold and underlines
    func createHightlightedDifferenceInAnswer(answer: String) -> [Int] {
        var editedAnswer = Array(answer.trim().lowercased())
        let correctAnswer = Array(wordForm.bare)
        var affectedIndices = [Int]()
        
        // loop through the correct answer array, on each step we will check to see if the letters at the i index are the same
        for i in 0..<correctAnswer.count {
            // if the inputted answer has less characters than the correct answer we can just start adding letters
            if i >= editedAnswer.count {
                editedAnswer.insert(correctAnswer[i], at: i)
                affectedIndices.append(i)
            } else if editedAnswer[i] != correctAnswer[i] {
                // we must first check to see if i + 1 is out of range, if its out of range then its a always an insert
                if i + 1 == editedAnswer.count || i + 1 == correctAnswer.count {
                    editedAnswer.insert(correctAnswer[i], at: i)
                    affectedIndices.append(i)
                    continue
                }
                
                else if editedAnswer[i] == correctAnswer[i + 1] {
                    editedAnswer.insert(correctAnswer[i], at: i)
                    affectedIndices.append(i)
                } else if editedAnswer[i] != correctAnswer[i + 1] {
                    editedAnswer.remove(at: i)
                    affectedIndices.append(i)
                    
                    // Dropping the word was enough to solve this issue so we can move to the next letter
                    // This is the case with an extra letter was typed
                    if editedAnswer[i] == correctAnswer[i] {
                        continue
                    }
                    
                    if i + 1 >= correctAnswer.count {
                        continue
                    }
                    
                    // Here we will check to see if the next index of the correct word is the same or not
                    // this case would deal with a completely incorrect letter and we are inserting a correct one
                    if editedAnswer[i] == correctAnswer[i + 1] {
                        editedAnswer.insert(correctAnswer[i], at: i)
                    // This case happens when we typed an extra letter but the proceeding letter is also wrong, so we just replace it and see what happens next round
                    } else {
                        editedAnswer[i] = correctAnswer[i]
                    }
                }
            }
        }
        
        return affectedIndices
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
}
