import GRDB

struct DatabaseSentence : Codable, Identifiable {
    var id: Int64
    var ru: String
    var level: String
}

extension DatabaseSentence : FetchableRecord, TableRecord {
    static let databaseTableName = "sentences"
    enum Columns {
        static let id = Column(CodingKeys.id)
    }
    static let associatedWords = hasMany(DatabaseSentenceWord.self)
    static let translation = hasOne(
            DatabaseSentenceTranslation.self,
            using: ForeignKey(["id"])
        )
}
