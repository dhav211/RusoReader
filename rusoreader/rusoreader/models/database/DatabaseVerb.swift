import GRDB

struct DatabaseVerb : Codable, Identifiable {
    var id: Int64
    var aspect: String
    var partner: String
    var word_id: Int64
}

extension DatabaseVerb : FetchableRecord, TableRecord {
    static let databaseTableName = "verbs"
    
    enum Columns {
        static let wordId = Column(CodingKeys.word_id)
    }
}

