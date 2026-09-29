import GRDB

struct FetchedBookInfo: Decodable, FetchableRecord {
    let book: DatabaseBook
    let chapterCount: Int
}
