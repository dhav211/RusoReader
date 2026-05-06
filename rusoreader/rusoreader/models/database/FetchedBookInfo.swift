import GRDB

struct FetchedBookInfo: Decodable, FetchableRecord {
    let book: DatabaseBook
    let chapters: [DatabaseChapter]
}
