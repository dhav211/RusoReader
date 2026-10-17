import Foundation
import UIKit

extension NSAttributedString {
    /// Creates an AttributedString with the correct answer compared to the user's answer, mistakes will be underlined to show where the user went wrong.
    /// - Parameters:
    ///   - answer: The answer the user typed into a text field,
    ///   - wordForm: The word form object which will be used to compare the user's answer. Requires the word form object because occasionally word forms will have multiple types, this function will determine which one the user wanted.
    /// - Returns: The correct answer with any mistakes underlined
    static func highlightedAnswer(from answer: String, wordForm: WordForm) -> NSAttributedString {
        let attributedAnswer = NSMutableAttributedString(string: findClosestWordFormVariation(to: answer, from: wordForm))
        let highlightedDifference = createHightlightedDifferenceInAnswer(answer: answer, wordForm: wordForm)
        // we are grabbing the default text so we can get a bold font point size here in the attributed string
        let defaultFont = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        
        for affectedIndex in highlightedDifference {
            attributedAnswer.addAttributes(
                [
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .font: UIFont.boldSystemFont(ofSize: defaultFont.pointSize)
                ],
                range: NSRange(location: affectedIndex, length: 1))
        }
        
        return attributedAnswer
    }
    
    private static func createHightlightedDifferenceInAnswer(answer: String, wordForm: WordForm) -> [Int] {
        // We will need to replace any ё with a e for the user's sake
        var editedAnswer = Array(
            answer
                .lowercased()
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "ё", with: "е")
        )
        // There exists words that have multiple forms, if we do run across one just check to see which version the user was closest to and compare it to that
        // We may run into issues here but regardless the user's answer was wrong
        let correctAnswer = wordForm.bare.contains(",")
            ? Array(findClosestWordFormVariation(to: answer.replacingOccurrences(of: "ё", with: "е"), from: wordForm))
            : Array(wordForm.bare.replacingOccurrences(of: "ё", with: "е"))
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
    
    private static func findClosestWordFormVariation(to answer: String, from wordForm: WordForm) -> String {
        typealias WordFormComparasion = (wordForm: String, comparasionDistance: Int)
        let wordFormComparasions: [WordFormComparasion] = wordForm.bare.split(separator: ",").map {
            let compared = String($0)
            return (wordForm: compared, comparasionDistance: StringComparasion.compare(answer, compared))
        }
        
        return wordFormComparasions.sorted(by: { $0.comparasionDistance < $1.comparasionDistance }).first?.wordForm ?? wordForm.bare
    }
}
