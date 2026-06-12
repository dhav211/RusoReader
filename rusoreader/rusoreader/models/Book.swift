import Foundation

struct Book {
    var id: Int
    var name: String
    var author: String
    var coverImageUrl: String?
    var currentChapter: Int
    var isbn: String?
    var uuid: String?
    var dateLastOpened: Date
    var dateCreated: Date
    
    init(id: Int, name: String, author: String, coverImageUrl: String?, currentChapter: Int, isbn: String? = nil, uuid: String? = nil, dateLastOpened: Date, dateCreated: Date) {
        self.id = id
        self.name = name
        self.author = author
        self.coverImageUrl = coverImageUrl
        self.currentChapter = currentChapter
        self.isbn = isbn
        self.uuid = uuid
        self.dateLastOpened = dateLastOpened
        self.dateCreated = dateCreated
    }
}
