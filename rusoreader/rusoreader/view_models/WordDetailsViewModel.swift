class WordDetailsViewModel {
    private let word: Word
    private let wordService: WordService
    private let sentenceService: SentenceService
    
    init(word: Word, wordService: WordService, sentenceService: SentenceService) {
        self.word = word
        self.wordService = wordService
        self.sentenceService = sentenceService
    }
    
    func getWordType() -> Word.WordType {
        return word.type
    }

    func getVerbAspect() -> Verb.Aspect? {
        return word.verb?.aspect
    }
    
    func getWordText() -> String {
        return wordService.addStress(to: word.accented)
    }
    
    func getTranslations() -> [String] {
        return word.translations.map { translation in
            return "- \(translation)"
        }
    }
    
    func getSentences() -> [Sentence] {
        return wordService.findSentences(by: word.id)
    }
    
    func addWordToDictionary() {
        wordService.addWordToUserDictionary(word: word)
    }
    
    func addStressToSentence(sentence: String) -> String {
        return sentence
            .split(separator: " ")
            .map { word in
                return wordService.addStress(to: String(word))
            }.joined(separator: " ")
    }
    
    /// Word information will change depending on its part of speech (noun, verb, etc), wether it's animate or inanimate, etc
    /// - Parameter word: The word we will get the information for
    /// - Returns: A string value which has been creating by checking variables in the word object
    func getWordInformation() -> String {
        var information = ""
        
        switch word.type {
        case .noun:
            information.append("Noun")
            if let noun = word.noun {
                if noun.gender == Noun.Gender.female {
                    information.append(", female")
                } else if noun.gender == Noun.Gender.male {
                    information.append(", male")
                } else if noun.gender == Noun.Gender.neuter {
                    information.append(", neuter")
                } else {
                    information.append(", male & female")
                }
                
                if noun.animate {
                    information.append(", animate")
                } else {
                    information.append(", inanimate")
                }
            }
        case .verb:
            information.append("Verb")
            if let verb = word.verb {
                information.append(", \(verb.aspect.rawValue)")
            }
        case .adjective:
            information.append("Adjective")
        case .adverb:
            information.append("Adverb")
        case.other:
            break
        }
        
        return information
    }
    
    /// Get easy to read ranking for the user to see
    /// - Parameter ranking: The total value ranking of the word, could be something like 23503, which isn't completely useful to a user
    /// - Returns: A string value which converts 23503 to Top 25000
    func getRankingTitle() -> String {
        if word.ranking >= 0 && word.ranking <= 10 {
            return "Top 10"
        } else if word.ranking > 10 && word.ranking <= 100 {
            return "Top 100"
        } else if word.ranking > 100 && word.ranking <= 10_000 {
            let rankingMultipler : Int = word.ranking / 500
            let isEdgePosition: Bool = word.ranking % 500 == 0 ? true : false
            return "Top \((rankingMultipler + (isEdgePosition ? 0 : 1)) * 500)"
        } else if word.ranking > 10_000 && word.ranking <= 50_000 {
            let rankingMultipler : Int = word.ranking / 5000
            let isEdgePosition: Bool = word.ranking % 5000 == 0 ? true : false
            return "Top \((rankingMultipler + (isEdgePosition ? 0 : 1)) * 5000)"
        } else {
            return "Very rarely used"
        }
    }
    
    func createGrammarFormTableData(grammarTableType: GrammarFormTableData.TableType) -> GrammarFormTableData{
        var forms = [String: WordForm]()
        for form in word.forms {
            forms[form.form.rawValue] = form
        }
        return GrammarFormTableData(wordForms: forms, grammarTableType: grammarTableType)
    }
    
    func getLongestRows(grammarFormTableData: GrammarFormTableData) -> [Int] {
        var longestRows = [Int]()
        for i in 0..<grammarFormTableData.forms.count {
            var currentLongestRowIndex = 0
            for j in 0..<grammarFormTableData.forms[i].count {
                let longestVariation = grammarFormTableData.forms[i][j].text.split(separator: ",")
                    .sorted() { $0.count > $1.count }
                    .first?.count ?? 0
                
                if longestVariation > grammarFormTableData.forms[i][currentLongestRowIndex].text.count {
                    currentLongestRowIndex = j
                }
            }
            longestRows.append(currentLongestRowIndex)
        }
        return longestRows
    }
    
    /// The database can contain multiple varations of a single word form. When they are retrieved from the database they are concatenated with a comma. This wil split them and present them in a string form that will be easy to read for the user
    /// - Parameters:
    ///   - rowCellData: A simple struct which contains the text of the word and wether or not its a word form
    /// - Returns: An array of strings which contain the presentable form of the word
    func getWordFormVariations(for rowCellData: GrammarFormTableData.Cell) -> [String] {
        return rowCellData.text.split(separator: ",").map { varation in
            return getLabelTextFromCell(wordText: String(varation), isRussianWord: rowCellData.isRussianWord, isAdjective: word.type == .adjective)
        }
    }
    
    /// Generates a label text from a given cell's word text based on its language and type.
    /// - Parameters:
    ///    - wordText: The original word text from the cell.
    ///    - isRussianWord: A boolean indicating whether the word is in Russian.
    ///    - isAdjective: A boolean indicating whether the word is an adjective.
    /// - Returns: A string representing the generated label text for the cell.
    private func getLabelTextFromCell(wordText: String, isRussianWord: Bool, isAdjective: Bool) -> String {
        if isRussianWord {
            var stressedRussianWord = ""
            if !isAdjective {
                stressedRussianWord = wordService.addStress(to: wordText)
            } else {
                if wordText.count > 5 { // If an adjective is longer than 5 letters then lets just display the endings
                    stressedRussianWord = wordService.addStress(to: getAdjectiveEnding(for: wordText))
                } else {
                    stressedRussianWord = wordService.addStress(to: wordText)
                }
            }
            return stressedRussianWord
        } else {
            return wordText
        }
    }
    
    /// Extracts and returns the ending part of an adjective.
    /// - Parameters:
    ///   - adjective: The adjective from which to extract the ending part, as a `String`.
    /// - Returns: A string representing the extracted ending part of the adjective.
    private func getAdjectiveEnding(for adjective: String) -> String {
        let adjectiveBase = wordService.findAdjectiveBase(for: adjective)
        guard let baseRange = adjective.range(of: adjectiveBase) else { return ""}
        return "-\(adjective[baseRange.upperBound..<adjective.endIndex])"
    }
}
