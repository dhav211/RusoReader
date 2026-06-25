import GRDB

class SentenceRepository {
    let databaseManager: DatabaseManager
    
    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
    }
    
    func findSentences(by wordId: Int) -> [Sentence] {
        do {
            return try databaseManager.wordQueue.read { db in
                let sentenceIds = try Row.fetchAll(db, sql: "SELECT sentence_id FROM sentence_words WHERE word_id = ?", arguments: [Int64(wordId)])
                    .shuffled()
                    .prefix(25)
                    .map { row in
                        return row["sentence_id"] as Int64
                    }
                
                let request: SQLRequest<Row> = "SELECT s.*, t.en FROM sentences s LEFT JOIN sentence_translations t ON t.id = s.id WHERE s.id IN \(sentenceIds)"
                let rows = try Row.fetchAll(db, request)
                
                return rows.map { row in
                    return Sentence(text: row["ru"], translation: row["en"], level: row["level"])
                }
                return []
            }
        } catch {
            print("Error: \(error)")
            return []
        }
    }
}
