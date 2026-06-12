import GRDB

struct DatabaseChapter : Codable, Identifiable, MutablePersistableRecord {
    var id: Int64?
    var name: String
    var position: Int64
    var current_user_progress: Int64
    var text: String
    var book_id: Int64
    
    init(id: Int64? = nil, name: String, position: Int64, current_user_progress: Int64, text: String, book_id: Int64) {
        self.id = id
        self.name = name
        self.position = position
        self.current_user_progress = current_user_progress
        self.text = text
        self.book_id = book_id
    }
    
    init(name: String, position: Int64, text: String) {
        self.init(id: nil, name: name, position: position, current_user_progress: 0, text: text, book_id: 0)
    }
    
    mutating func didInsert(_ inserted: InsertionSuccess) {
        self.id = inserted.rowID
    }
}

extension DatabaseChapter : FetchableRecord, TableRecord {
    static let databaseTableName = "chapters"
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let bookId = Column(CodingKeys.book_id)
        static let position = Column(CodingKeys.position)
        static let currentProgress = Column(CodingKeys.current_user_progress)
    }
}
