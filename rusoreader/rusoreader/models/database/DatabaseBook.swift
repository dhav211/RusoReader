import GRDB
import Foundation

struct DatabaseBook : Codable, Identifiable, MutablePersistableRecord {
    var id: Int64?
    var name: String
    var file_url: String
    var cover_image_url: String
    var current_chapter: Int64
    var isbn: String?
    var uuid: String?
    var date_last_opened: Date
    var date_created: Date
    
    init(id: Int64? = nil, name: String, file_url: String, cover_image_url: String, current_chapter: Int64, isbn: String?, uuid: String?) {
        self.id = nil
        self.name = name
        self.file_url = file_url
        self.cover_image_url = cover_image_url
        self.current_chapter = current_chapter
        self.isbn = isbn
        self.uuid = uuid
        self.date_last_opened = Date()
        self.date_created = Date()
    }
    
    mutating func didInsert(_ inserted: InsertionSuccess) {
        self.id = inserted.rowID
    }
}

extension DatabaseBook : FetchableRecord, TableRecord {
    static let databaseTableName = "books"
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let lastOpened = Column(CodingKeys.date_last_opened)
        static let created = Column(CodingKeys.date_created)
    }
    
    static let chapters = hasMany(DatabaseChapter.self)
}

