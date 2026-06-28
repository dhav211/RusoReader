import GRDB
import Foundation

struct DatabaseDictionaryWord : Codable, Identifiable, MutablePersistableRecord {
    var id: Int64 // The id is the same as the word_id it is associated with
    var score: Int64
    var times_clicked: Int64
    var times_appeared: Int64
    var first_seen: Date
    var last_seen: Date
    var due_date: Date?
}

extension DatabaseDictionaryWord : FetchableRecord, TableRecord {
    static let databaseTableName = "user_dictionary"
    enum Columns {
        static let id = Column(CodingKeys.id)
    }
}
