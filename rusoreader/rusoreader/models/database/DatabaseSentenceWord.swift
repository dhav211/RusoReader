import GRDB

struct DatabaseSentenceWord : Codable, Identifiable {
    var id: Int64
    var sentence_id: Int64
    var word_id: Int64
    var start: Int64
    var length: Int64
    var form_type: String
}

extension DatabaseSentenceWord : FetchableRecord, TableRecord {
    static let databaseTableName = "sentence_words"
    enum Columns {
        static let id = Column(CodingKeys.id)
    }
}

