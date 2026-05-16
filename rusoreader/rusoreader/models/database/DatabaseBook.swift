import GRDB
import Foundation

struct DatabaseBook : Codable, Identifiable, MutablePersistableRecord {
    var id: Int64?
    var name: String
    var author: String
    var cover_image_url: String?
    var current_chapter: Int64
    var isbn: String?
    var uuid: String?
    var date_last_opened: Date
    var date_created: Date
    
    init(id: Int64? = nil, name: String, author: String, cover_image_url: String?, current_chapter: Int64, isbn: String?, uuid: String?) {
        self.id = nil
        self.name = name
        self.author = author
        self.cover_image_url = cover_image_url
        self.current_chapter = current_chapter
        self.isbn = isbn
        self.uuid = uuid
        self.date_last_opened = Date()
        self.date_created = Date()
    }
    
    init(name: String, isbn: String?, uuid: String?) {
        self.init(id: nil, name: name, author: "", cover_image_url: nil, current_chapter: 0, isbn: isbn, uuid: uuid)
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

