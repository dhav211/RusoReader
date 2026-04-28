import GRDB

struct DatabaseWord : Codable, Identifiable {
    var id: Int64
    var bare: String
    var accented: String
    var type: String
    var level: String
}

extension DatabaseWord : FetchableRecord, TableRecord {
    static let databaseTableName = "words"
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let bare = Column(CodingKeys.bare)
        static let accented = Column(CodingKeys.accented)
        static let type = Column(CodingKeys.type)
        static let level = Column(CodingKeys.level)
    }
    static let verb = hasOne(DatabaseVerb.self)
    static let noun = hasOne(DatabaseNoun.self)
    static let translations = hasMany(DatabaseTranslation.self)
    static let wordForms = hasMany(DatabaseWordForm.self)
}
