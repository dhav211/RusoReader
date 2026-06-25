import GRDB

struct DatabaseSentenceTranslation : Codable, Identifiable {
    var id: Int64
    var en: String
}

extension DatabaseSentenceTranslation : FetchableRecord, TableRecord {
    static let databaseTableName = "sentence_translations"
    enum Columns {
        static let id = Column(CodingKeys.id)
    }
}
