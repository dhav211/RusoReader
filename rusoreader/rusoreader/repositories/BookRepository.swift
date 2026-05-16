import GRDB
import Foundation

class BookRepository {
    let databaseManager: DatabaseManager
    let fileStore: FileStore
    
    init(databaseManager: DatabaseManager, fileStore: FileStore) {
        self.databaseManager = databaseManager
        self.fileStore = fileStore
    }
    
    func saveBook(parsedBook: ParsedBook) -> Book? {
        do {
            return try databaseManager.userDataQueue.write { db in
                let coverImageUrl: URL? = try {
                    if let coverImage = parsedBook.book.coverImage {
                        return try fileStore.save(data: coverImage, fileName: "\(parsedBook.book.title.replacingOccurrences(of: " ", with: "-").lowercased())-cover-image\(parsedBook.book.coverImageFileType)")
                    } else {
                        return nil
                    }
                }()
                
                var book = DatabaseBook(name: parsedBook.book.title, cover_image_url: coverImageUrl?.path() ?? "", current_chapter: 1, isbn: parsedBook.book.isbn, uuid: parsedBook.book.uuid)
                
                try book.insert(db)
                
                var chapters = [DatabaseChapter]()
                for parsedChapter in parsedBook.chapters {
                    var chapter = DatabaseChapter(name: parsedChapter.title, index: Int64(parsedChapter.index), current_user_progress: 0, text: parsedChapter.text, book_id: book.id ?? 0)
                    try chapter.insert(db)
                    chapters.append(chapter)
                }
                
                return createBook(from: FetchedBookInfo(book: book, chapters: chapters))
            }
        } catch {
            print("Error saving book: \(error)")
            return nil
        }
    }
    
    func findBooksBy(title: String) -> [Book] {
        do {
            return try databaseManager.userDataQueue.read { db in
                let request = DatabaseBook
                    .filter(DatabaseBook.Columns.name.uppercased == title.uppercased())
                    .including(all: DatabaseBook.chapters)
                    .asRequest(of: FetchedBookInfo.self)
                
                return try FetchedBookInfo.fetchAll(db, request).map { fetchedBook in
                    return createBook(from: fetchedBook)
                }
            }
        } catch {
            print("Error loading book by title of \(title). Error: \(error)")
            return [Book]()
        }
    }
    
    private func createBook(from fetchBookInfo: FetchedBookInfo) -> Book {
        let chapters = fetchBookInfo.chapters.map { dbChapter in
            return Chapter(
                name: dbChapter.name,
                index: Int(dbChapter.index),
                currentUserProgress: Int(dbChapter.current_user_progress),
                text: dbChapter.text
            )
        }
        
        return Book(
            name: fetchBookInfo.book.name,
            chapters: chapters,
            coverImageUrl: fetchBookInfo.book.cover_image_url,
            currentChapter: Int(fetchBookInfo.book.current_chapter),
            dateLastOpened: fetchBookInfo.book.date_last_opened,
            dateCreated: fetchBookInfo.book.date_created)
    }
}
