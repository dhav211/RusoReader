import GRDB

struct DatabaseTranslation : Codable, Identifiable {
    var id: Int64
    var position: Int64
    var tl: String
    var word_id: Int64
}

extension DatabaseTranslation : FetchableRecord, TableRecord {
    static let databaseTableName = "translations"
    enum Columns {
        static let wordId = Column(CodingKeys.word_id)
    }
}

