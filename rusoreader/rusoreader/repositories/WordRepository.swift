import GRDB

class WordRepository {
    let databaseManager: DatabaseManager
    
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
    }
    
    /// Finds matches for given word IDs by fetching their corresponding word information and creating Word objects.
    ///
    /// This function relies on two other functions: `fetchWordInfos(by:in:)` to fetch word information from the database, and `createWords(from:)` to transform the fetched information into `[Word]` objects.
    /// - Parameters:
    ///   - wordIds: The IDs of words to find matches for, as an array of `[Int64]`.
    /// - Returns: An array of `[Word]` objects representing the matched words. If an error occurs during the fetch or transformation, an empty array is returned and an error message is printed.
    func findMatches(by wordIds: [Int64]) -> [Word] {
        do {
            return try databaseManager.wordQueue.read { db in
                let wordInfos = fetchWordInfos(by: wordIds, in: db)
                return createWords(from: wordInfos)
            }
        } catch {
            print("Error: \(error)")
            return []
        }
    }
    
    /// Fetches word information from the database using given IDs.
    ///
    /// This function performs a batch fetch to improve performance.
    /// - Parameters:
    ///   - ids: The IDs of words to fetch, as an array of `[Int64]`.
    ///   - db: The database instance to use for the fetch, as a `Database` object.
    /// - Returns: An array of `[FetchedWordInfo]` objects representing the fetched word information. If an error occurs during the fetch, an empty array is returned and an error message is printed.
    private func fetchWordInfos(by ids: [Int64], in db: Database) -> [FetchedWordInfo] {
        do {
            let request = DatabaseWord
                .filter(ids: ids)
                .including(optional: DatabaseWord.noun)
                .including(optional: DatabaseWord.verb)
                .including(all: DatabaseWord.translations)
                .including(all: DatabaseWord.wordForms.forKey("wordForms"))
                .asRequest(of: FetchedWordInfo.self)
            
            return try FetchedWordInfo.fetchAll(db, request)
        } catch {
            print("Error: \(error)")
            return []
        }
    }
    
    /// Finds IDs of words in the database that match a given search term.
    ///
    /// This function performs fuzzy matching to account for variations in Cyrillic letters (e.g., "е" vs. "ё").
    /// - Parameters:
    ///   - bare: The search term to look up, as a lowercase string.
    /// - Returns: An array of `[Int64]` values representing the IDs of matching words. If no matches are found, an empty array is returned.
    func findWordIDs(by bare: String) -> [Int64] {
        let searchTerm = bare.lowercased()
        var searches = [searchTerm]
        
        // Oftentimes russian texts ommit the ё but our database requires it. So add it to any word that has a e but no ё
        if searchTerm.contains("е") && !searchTerm.contains("ё") {
            for letter in 0..<bare.count {
                if searchTerm[searchTerm.index(searchTerm.startIndex, offsetBy: letter)] == "е" {
                    var replaceLetter = searchTerm
                    let startIndex = replaceLetter.index(replaceLetter.startIndex, offsetBy: letter)
                    let endIndex = replaceLetter.index(replaceLetter.startIndex, offsetBy: letter + 1)
                    replaceLetter.replaceSubrange(startIndex..<endIndex, with: "ё")
                    searches.append(replaceLetter)
                }
            }
        }
        
        do {
            return try databaseManager.wordQueue.read { db in
                let wordFormIds = try DatabaseWordForm
                    .select(DatabaseWordForm.Columns.wordId, as: Int64.self)
                    .filter(searches.contains(DatabaseWordForm.Columns.bare))
                    .distinct()
                    .fetchAll(db)
                
                // If a search comes up empty, then it may be a base form for a verb, so search the word table as a last effort
                if wordFormIds.isEmpty {
                    return try DatabaseWord
                        .select(DatabaseWord.Columns.id, as: Int64.self)
                        .filter(searches.contains(DatabaseWord.Columns.bare))
                        .distinct()
                        .fetchAll(db)
                } else {
                    return wordFormIds
                }
            }
        } catch {
            print("Error: \(error)")
            return []
        }
    }
    
    /// Takes a list of `FetchedWordInfo` objects and returns a new array of `Word` objects.
    ///
    /// Each `Word` object is created by extracting relevant information from the corresponding `FetchedWordInfo`.
    /// - Parameters:
    ///   - wordInfos: A list of `FetchedWordInfo` objects to process.

    /// - Returns: An array of `[Word]` objects, where each element corresponds to a `FetchedWordInfo` in the input list.
    private func createWords(from wordInfos: [FetchedWordInfo]) -> [Word] {
        var words = [Word]()
        
        for wordInfo in wordInfos {
            var noun: Noun?
            var verb: Verb?
            let wordType = Word.WordType(rawValue: wordInfo.word.type) ?? Word.WordType.other
            
            if let dbNoun = wordInfo.noun {
                noun = Noun(dbNoun: dbNoun)
            }
            
            if let dbVerb = wordInfo.verb {
                verb = Verb(dbVerb: dbVerb)
            }
            
            let translations = wordInfo.translations.map { tranlsation in
                return tranlsation.tl
            }
            
//            var forms = [String:String]()
//            for form in wordInfo.wordForms {
//                if forms[form.form_type] != nil {
//                    forms[form.form_type]?.append(",\(form.form)")
//                } else {
//                    forms[form.form_type] = form.form
//                }
//            }
            
            var forms : [WordForm] = wordInfo.wordForms.map() { form in
                return WordForm(bare: form.form_bare, accented: form.form, form: Form(rawValue: form.form_type) ?? .error)
            }
            
            if wordType == .verb {
                forms.append(WordForm(bare: wordInfo.word.bare, accented: wordInfo.word.accented, form: .verbInfitive))
            }
            
            words.append(
                Word(
                    id: Int(wordInfo.word.id),
                    bare: wordInfo.word.bare,
                    accented: wordInfo.word.accented,
                    type: wordType,
                    level: wordInfo.word.level,
                    ranking: Int(wordInfo.word.id), // TODO we need to make the actual ranking in our DB and not use word id
                    noun: noun,
                    verb: verb,
                    forms: forms,
                    translations: translations)
            )
        }
        
        return words
    }
    
    /// Find all forms of a word by it's ID
    /// - Parameter wordId: The ID of a word
    /// - Returns: An array of strings which hold all the unique forms of the word
    func findUniqueWordForms(for wordId: Int) -> [String] {
        do {
            return try databaseManager.wordQueue.read { db in
                return try DatabaseWordForm
                    .filter { $0.wordId == Int64(wordId) }
                    .distinct()
                    .fetchAll(db)
                    .map { return $0.form_bare }
            }
        } catch {
            print("Error: \(error)")
            return []
        }
    }
    
    /// Find all forms with stress marks of a word by it's ID
    /// - Parameter wordId: The ID of a word
    /// - Parameter accentedBaseForm: The accented form of the word, will be used to compare if infinitive is in the word form which for verbs it's often not
    /// - Returns: An array of strings which hold all the unique forms of the word
    func findUniqueStressedWordForms(accentedBaseForm: String, wordId: Int) -> [String] {
        do {
            return try databaseManager.wordQueue.read { db in
                var uniqueForms = try DatabaseWordForm
                    .filter { $0.wordId == Int64(wordId) }
                    .distinct()
                    .fetchAll(db)
                    .map { return $0.form }
                
                if !uniqueForms.contains(accentedBaseForm) {
                    uniqueForms.append(accentedBaseForm)
                }
                
                return uniqueForms
            }
        } catch {
            print("Error: \(error)")
            return []
        }
    }
    
    func findAllWordForms(for word: Word) -> [WordForm] {
        do {
            let dbWordForms = try databaseManager.wordQueue.read { db in
                return try DatabaseWordForm
                    .filter { $0.wordId == Int64(word.id) }
                    .fetchAll(db)
            }
            
            var wordForms = [WordForm]()
            if word.type == .verb {
                wordForms.append(WordForm(bare: word.bare, accented: word.accented, form: .verbInfitive))
            }
            
            return [WordForm]()
        } catch {
            print("Error: \(error)")
            return []
        }
    }
}
