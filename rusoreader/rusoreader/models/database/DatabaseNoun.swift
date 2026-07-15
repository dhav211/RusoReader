import GRDB

struct DatabaseNoun : Codable, Identifiable {
    var id: Int64
    var gender: String
    var partner: String
    var animate: DatabaseBool
    var indeclinable: DatabaseBool
    var sg_only: DatabaseBool
    var pl_only: DatabaseBool
    var word_id: Int64
    
    enum CodingKeys: String, CodingKey {
        case word_id
        case partner
        case animate
        case gender
        case indeclinable
        case sg_only
        case pl_only
        case id
    }
}

extension DatabaseNoun : FetchableRecord, TableRecord {
    static let databaseTableName = "nouns"
    enum Columns {
        static let wordId = Column(CodingKeys.word_id)
    }
}
