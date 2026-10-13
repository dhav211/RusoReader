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
        let checkable = cleanAnswerInput(answer)
        let stems = wordService.getWordStems(of: word)
        
        var results = [ExerciseResult.Grade]()
        
        for stem in stems {
            for splitForm in wordForm.bare.split(separator: ",") {
                // first we will isolate the ending of the word as this is what this exercise is testing
                guard let endingIndex = splitForm.index(splitForm.startIndex, offsetBy: stem.count, limitedBy: splitForm.endIndex) else {
                    //return ExerciseResult(word: word, grade: .error, score: 0)
                    results.append(.error)
                    continue
                }
                let ending = splitForm[endingIndex..<splitForm.endIndex]
                
                if !checkable.hasSuffix(ending) {
                    //return ExerciseResult(word: word, grade: .incorrect, score: 1)
                    results.append(.incorrect)
                    continue
                }
                
                // now we will check the stem, in this exercise its not as important so we can be a letter or two off depending on word length
                let checkableStem = String(checkable[checkable.startIndex..<checkable.index(checkable.endIndex, offsetBy: -ending.count)])
                let differenceTolerance = max(checkableStem.count / 10, 1)
                let difference = StringComparasion.compare(stem, checkableStem)
                
                // an exact match is considered correct with full points
                if difference == 0 {
                    results.append(.correct)
                    // if it's within tolerance points are still rewarded but let the user know they weren't fully correct
                } else if difference > 0 && difference <= differenceTolerance {
                    results.append(.almost)
                    // out of tolerance means the exercise was wrong, points will be affected and user must try again
                } else {
                    results.append(.incorrect)
                }
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
    
    /// Finds the differences in the users answer with the actual answer
    /// - Parameter answer: The user's input from a text field
    /// - Returns: An array of ints which show which letters are different, this will be used to create an AttributedString with bold and underlines
    func createHightlightedDifferenceInAnswer(answer: String) -> [Int] {
        var editedAnswer = Array(answer.trim().lowercased())
        let correctAnswer = wordForm.bare.contains(",") ? Array(findClosestWordFormVariation(to: answer)) : Array(wordForm.bare)
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
    
    func findClosestWordFormVariation(to answer: String) -> String {
        typealias WordFormComparasion = (wordForm: String, comparasionDistance: Int)
        let wordFormComparasions: [WordFormComparasion] = wordForm.bare.split(separator: ",").map {
            let compared = String($0)
            return (wordForm: compared, comparasionDistance: StringComparasion.compare(answer, compared))
        }
        
        return wordFormComparasions.sorted(by: { $0.comparasionDistance < $1.comparasionDistance }).first?.wordForm ?? wordForm.bare
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
