import GRDB
import Foundation

struct DatabaseBook : Codable, Identifiable {
    var id: Int64
    var name: String
    var file_url: String
    var cover_image_url: String
    var current_chapter: Int64
    var isbn: String
    var uuid: String
    var date_last_opened: Date
    var date_created: Date
}

extension DatabaseBook : FetchableRecord, PersistableRecord, TableRecord {
    static let databaseTableName = "words"
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let lastOpened = Column(CodingKeys.date_last_opened)
        static let created = Column(CodingKeys.date_created)
    }
    
    static let chapters = hasMany(DatabaseChapter.self)
}

