import Foundation

struct Book {
    let id: Int
    var name: String
    var author: String
    let coverImageUrl: String?
    let currentChapter: Int
    let numberOfChapters: Int
    let isbn: String?
    let uuid: String?
    let dateLastOpened: Date?
    let dateCreated: Date
    
    init(id: Int, name: String, author: String, coverImageUrl: String?, currentChapter: Int, numberOfChapters: Int = 0,
         isbn: String? = nil, uuid: String? = nil, dateLastOpened: Date? = nil, dateCreated: Date) {
        self.id = id
        self.name = name
        self.author = author
        self.coverImageUrl = coverImageUrl
        self.currentChapter = currentChapter
        self.numberOfChapters = numberOfChapters
        self.isbn = isbn
        self.uuid = uuid
        self.dateLastOpened = dateLastOpened
        self.dateCreated = dateCreated
    }
}
