import Foundation
class SentenceService {
    let sentenceRepo: SentenceRepository
    let wordRepo: WordRepository
    let wordService: WordService
    
    init(sentenceRepo: SentenceRepository, wordRepo: WordRepository, wordService: WordService) {
        self.sentenceRepo = sentenceRepo
        self.wordRepo = wordRepo
        self.wordService = wordService
    }
    
    /// Returns a maximum of 25 random sentences which contain the word owned by this word id
    /// - Parameter wordId: The id of the word we are getting sentences
    /// - Returns: A max limit of 25 random sentences containing the given word id
    func findSentences(by wordId: Int) -> [Sentence] {
        return sentenceRepo.findSentences(by: wordId)
    }
    
    func findSingleSentence(by wordId: Int) -> Sentence? {
        if let sentence = findSentences(by: wordId).first {
            return sentence
        }
        
        return nil
    }
    
    /// Finds the index range of word (in all it's forms) in a sentence
    /// - Parameters:
    ///   - word: The word we will find the range for, this will get all forms of the word to search for a matching range in the sentence
    ///   - sentence: The sentence from the database
    /// - Returns: If a form of the word is found in the sentence a NSRange will be return if not it will send back nil
    func getRange(of word: Word, in sentence: String) -> NSRange? {
        let wordForms = wordRepo
            .findWordIDs(by: word.bare)
            .map { return wordRepo.findUniqueStressedWordForms(for: Int($0))}
            .joined()
        
        return findRange(wordForms: Array(wordForms), sentence: sentence)
    }
    
    /// Adding the unicode stress marks to the letters after getting the range will throw off the indices, you must first add the stress and then run this function. This will add stress marks to all word forms to find a matching range.
    /// - Parameters:
    ///   - word: The word we will find the range for, this will get all forms of the word to search for a matching range in the sentence
    ///   - sentence: The sentence from the database
    /// - Returns: If a form of the word is found in the sentence a NSRange will be return if not it will send back nil
    func getRangeWithStress(of word: Word, in sentence: String) -> NSRange? {
        let wordForms = wordRepo
            .findWordIDs(by: word.bare)
            .map { return wordRepo.findUniqueStressedWordForms(for: Int($0))}
            .joined()
            .map { return wordService.addStress(to: $0)}
        
        return findRange(wordForms: wordForms, sentence: addStress(sentence: sentence))
    }
    
    private func findRange(wordForms: [String], sentence: String) -> NSRange? {
        for wordForm in wordForms {
            if sentence.lowercased().contains(wordForm), let range = sentence.lowercased().range(of: wordForm) {
                let range = NSRange(range, in: sentence.lowercased())
                return NSRange(location: range.location, length: range.length + 1)
            }
        }
        
        return nil
    }
    
    /// Adds stress to any words that have stress marks in them
    /// - Parameter sentence: The sentence will stress marks repersented as '
    /// - Returns: A sentence with unicode stressed characters
    func addStress(sentence: String) -> String {
        return sentence
            .split(separator: " ")
            .map { word in
                return wordService.addStress(to: String(word))
            }.joined(separator: " ")
    }
}
