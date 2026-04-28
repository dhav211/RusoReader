import GRDB

struct DatabaseNoun : Codable, Identifiable {
    var id: Int64
    var gender: String
    var partner: String
    var animate: Bool
    var indeclinable: Bool
    var sg_only: Bool
    var pl_only: Bool
    var word_id: Int64
}

extension DatabaseNoun : FetchableRecord, TableRecord {
    static let databaseTableName = "nouns"
    enum Columns {
        static let wordId = Column(CodingKeys.word_id)
    }
}
