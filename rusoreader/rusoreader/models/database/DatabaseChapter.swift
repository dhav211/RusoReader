import GRDB

struct DatabaseChapter : Codable, Identifiable, MutablePersistableRecord {
    var id: Int64?
    var name: String
    var index: Int64
    var current_user_progress: Int64
    var url: String
    var book_id: Int64
}

extension DatabaseChapter : FetchableRecord, TableRecord {
    static let databaseTableName = "chapters"
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let bookId = Column(CodingKeys.book_id)
    }
}
