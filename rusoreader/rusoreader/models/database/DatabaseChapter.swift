import GRDB

struct DatabaseChapter : Codable, Identifiable {
    var id: Int64
    var name: String
    var index: Int64
    var current_user_progress: Int64
    var book_id: Int64
}

extension DatabaseChapter : FetchableRecord, PersistableRecord, TableRecord {
    static let databaseTableName = "words"
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
    }
}
