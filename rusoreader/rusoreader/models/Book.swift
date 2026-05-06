import Foundation

struct Book {
    var name: String
    var chapters: [Chapter]
    var fileUrl: String
    var coverImageUrl: String
    var currentChapter: Int
    var isbn: String?
    var uuid: String?
    var dateLastOpened: Date
    var dateCreated: Date
    
    init(name: String, chapters: [Chapter], fileUrl: String, coverImageUrl: String, currentChapter: Int, isbn: String? = nil, uuid: String? = nil, dateLastOpened: Date, dateCreated: Date) {
        self.name = name
        self.chapters = chapters
        self.fileUrl = fileUrl
        self.coverImageUrl = coverImageUrl
        self.currentChapter = currentChapter
        self.isbn = isbn
        self.uuid = uuid
        self.dateLastOpened = dateLastOpened
        self.dateCreated = dateCreated
    }
}
