import GRDB

class SentenceRepository {
    let databaseManager: DatabaseManager
    
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
    }
    
    /// Finds a given number of sentences along with their translations, will only find sentences with translations
    /// - Parameters:
    ///   - wordId: The ID of the word we are looking sentences for
    ///   - sentenceLimit: The maximum number of sentences we want
    /// - Returns: The given limit of sentences along with their translations
    func findSentences(by wordId: Int, sentenceLimit: Int = 25) -> [Sentence] {
        do {
            return try databaseManager.wordQueue.read { db in
                let sentenceIds = try Row.fetchAll(db, sql: "SELECT sentence_id FROM sentence_words WHERE word_id = ?", arguments: [Int64(wordId)])
                    .map { row in
                        return row["sentence_id"] as Int64
                    }
                
                let request: SQLRequest<Row> = "SELECT s.*, t.en FROM sentences s LEFT JOIN sentence_translations t ON t.id = s.id WHERE s.id IN \(sentenceIds)"
                let rows = try Row.fetchAll(db, request)
                    .shuffled()
                    .prefix(sentenceLimit)
                
                return rows.map { row in
                    return Sentence(text: row["ru"], translation: row["en"], level: row["level"])
                }
            }
        } catch {
            print("Error: \(error)")
            return []
        }
    }
    
    /// Finds sentences that don't go over a certain character limit
    /// - Parameters:
    ///   - wordId: The ID of the word we are looking for
    ///   - limit: The maximum number of characters in the sentence
    /// - Returns: A character limited set of sentences
    func findSentencesWithLengthLimit(by wordId: Int, with limit: Int) -> [Sentence] {
        do {
            return try databaseManager.wordQueue.read { db in
                let sentenceIds = try Row.fetchAll(db, sql: "SELECT sentence_id FROM sentence_words WHERE word_id = ?", arguments: [Int64(wordId)])
                    .shuffled()
                    .map { row in
                        return row["sentence_id"] as Int64
                    }
                
                let request: SQLRequest<Row> = "SELECT s.*, t.en FROM sentences s LEFT JOIN sentence_translations t ON t.id = s.id WHERE s.id IN \(sentenceIds)"
                let rows = try Row.fetchAll(db, request)
                
                return rows.compactMap { row in
                    let sentence = Sentence(text: row["ru"], translation: row["en"], level: row["level"])
                    
                    if sentence.text.count <= limit {
                        return sentence
                    } else {
                        return nil
                    }
                }
            }
        } catch {
            print("Error: \(error)")
            return []
        }
    }
}
