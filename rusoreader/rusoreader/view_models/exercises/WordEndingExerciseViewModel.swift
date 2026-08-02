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
    /// - Parameter exerciseInput: A string value which is submited from a text field by the user
    /// - Returns: The grade the user will see and the associated score which will affect the spaced repetion algorithim
    func calculateResult(exerciseInput: String) -> ExerciseResult {
        // we will trim and lowercase the input so the user won't be dinged for accidently clicking space or capitializing a letter
        let checkable = exerciseInput.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let stem = wordService.getWordStem(of: word)
        
        // first we will isolate the ending of the word as this is what this exercise is testing
        let endingIndex = wordForm.bare.index(wordForm.bare.startIndex, offsetBy: stem.count)
        let ending = wordForm.bare[endingIndex..<wordForm.bare.endIndex]
        
        // the input strings ending must be the exact same as the word forms ending, if one letter off lets consider it a fail
        if checkable[checkable.index(checkable.endIndex, offsetBy: -ending.count)..<checkable.endIndex] != ending {
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
                if i + 1 >= editedAnswer.count || i + 1 >= correctAnswer.count {
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
    
    func getWordFormText() -> String {
        return wordService.addStress(to: wordForm.accented)
    }
    
    func getFormText() -> String {
        switch wordForm.form {
        case .adjectiveFemaleAccusative:
            return "Accusative in Female Form"
        case .adjectiveFemaleDative:
            return "Dative in Female Form"
        case .adjectiveFemaleGenitive:
            return "Genitive in Female Form"
        case .adjectiveFemaleInstrumental:
            return "Instrumental in Female Form"
        case .adjectiveFemalePrepositional:
            return "Prepositional in Female Form"
        case .adjectiveMaleAccusative:
            return "Accusative in Male Form"
        case .adjectiveMaleDative:
            return "Dative in Male Form"
        case .adjectiveMaleGenitive:
            return "Genitive in Male Form"
        case .adjectiveMaleInstrumental:
            return "Instrumental in Male Form"
        case .adjectiveMalePrepositional:
            return "Prepositional in Male Form"
        case .adjectiveNeuterAccusative:
            return "Accusative in Neuter Form"
        case .adjectiveNeuterDative:
            return "Dative in Neuter Form"
        case .adjectiveNeuterGenitive:
            return "Genitive in Neuter Form"
        case .adjectiveNeuterInstrumental:
            return "Instrumental in Neuter Form"
        case .adjectiveNeuterPrepositional:
            return "Prepositional in Neuter Form"
        case .adjectivePluralAccusative:
            return "Accusative in Plural Form"
        case .adjectivePluralDative:
            return "Dative in Plural Form"
        case .adjectivePluralGenitive:
            return "Genitive in Plural Form"
        case .adjectivePluralInstrumental:
            return "Instrumental in Plural Form"
        case .adjectivePluralPrepositional:
            return "Prepositional in Plural Form"
        case .nounSingularDative:
            return "Dative Singular"
        case .nounSingularGenitive:
            return "Genitive Singular"
        case .nounSingularAccusative:
            return "Accusative Singular"
        case .nounSingularInstrumental:
            return "Instrumental Singular"
        case .nounSingularPrepositional:
            return "Prepositional Singular"
        case .nounPluralDative:
            return "Dative Plural"
        case .nounPluralGenitive:
            return "Genitive Plural"
        case .nounPluralAccusative:
            return "Accusative Plural"
        case .nounPluralInstrumental:
            return "Instrumental Plural"
        case .nounPluralPrepositional:
            return "Prepositional Plural"
        case .verbPastMale:
            return "Past Tense, Masculine"
        case .verbPastFemale:
            return "Past Tense, Feminine"
        case .verbPastNeuter:
            return "Past Tense, Neuter"
        case .verbPastPlural:
            return "Past Tense, Plural"
        case .verbPresentFuturePluralFirst:
            return "Present/Future, We"
        case .verbPresentFuturePluralSecond:
            return "Present/Future, You (Plural)"
        case .verbPresentFuturePluralThird:
            return "Present/Future, They"
        case .verbPresentFutureSingularFirst:
            return "Present/Future, I"
        case .verbPresentFutureSingularSecond:
            return "Present/Future, You"
        case .verbPresentFutureSingularThird:
            return "Present/Future, He/She/It"
        default:
            return ""
        }
    }
}
