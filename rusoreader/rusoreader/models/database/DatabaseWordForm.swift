import GRDB

struct DatabaseWordForm : Codable, Identifiable {
    var id: Int64
    var form_type: String
    var position: Int64
    var form: String
    var form_bare: String
    var word_id: Int64
}

extension DatabaseWordForm : FetchableRecord, TableRecord {
    static let databaseTableName = "word_forms"
    enum Columns {
        static let bare = Column(CodingKeys.form_bare)
        static let accented = Column(CodingKeys.form)
        static let wordId = Column(CodingKeys.word_id)
    }
}
