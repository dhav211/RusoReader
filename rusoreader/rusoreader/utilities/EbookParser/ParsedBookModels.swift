import Foundation

/// A simple data object which is used to hold information on the book until it is time to save it to the database
struct BookDetails {
    let title: String
    let author: String
    let isbn: String
    let uuid: String
    let language: String
    var coverImage: Data?
    var coverImageFileType: String
    
    init(title: String, author: String, isbn: String, uuid: String, language: String) {
        self.title = title
        self.author = author
        self.isbn = isbn
        self.uuid = uuid
        self.language = language
        self.coverImage = nil
        self.coverImageFileType = ""
    }
}

struct ChapterDetails {
    let index: Int
    let title: String
    let text: String
}

struct ParsedBook {
    let book: BookDetails
    let chapters: [ChapterDetails]
}
