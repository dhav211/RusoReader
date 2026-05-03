import GRDB
import UIKit
import Foundation
final class DatabaseManager {
    private(set) var wordQueue: DatabaseQueue!
    private(set) var bookQueue: DatabaseQueue!
    
    init() {
        do {
            // The words DB is read-only so we can just grab it from the app bundle
            if let wordUrl = Bundle.main.url(forResource: "words", withExtension: "db") {
                wordQueue = try DatabaseQueue(path: wordUrl.path())
            }
            
            bookQueue = getWritableDatabaseQueue(by: "books.db")

            // Use the migrator to actually create migrations for any possible changes, you will need to check the documention on how to alter tables later
            if bookQueue != nil {
                var migrator = DatabaseMigrator()
                migrator.registerMigration("Creates books") { db in
                    try db.create(table: "books") { booksTable in
                        booksTable.primaryKey("id", .integer)
                        booksTable.column("name", .text).notNull()
                        booksTable.column("file_url", .text).notNull()
                        booksTable.column("cover_image_url", .text)
                        booksTable.column("current_chapter", .integer).notNull()
                        booksTable.column("isbn", .text)
                        booksTable.column("uuid", .text)
                        booksTable.column("date_last_opened", .date)
                        booksTable.column("date_created", .date)
                    }
                }
                
                migrator.registerMigration("Creates chapters") { db in
                    try db.create(table: "chapters") { chaptersTable in
                        chaptersTable.primaryKey("id", .integer)
                        chaptersTable.column("name", .text)
                        chaptersTable.column("index", .integer)
                        chaptersTable.column("current_user_progress", .integer)
                        chaptersTable.column("book_id", .integer)
                    }
                }
                try migrator.migrate(bookQueue)
            } else {
                throw DatabaseManagerError.notFound("Can't find database by name chapters.db")
            }
            
        
        } catch {
            fatalError("Failed to initialize the database: \(error)")
        }
    }
    
    /// Retrieves a writable database queue for the specified database name.
    ///
    /// This function creates a path to the database file within the application's support directory and attempts to initialize a DatabaseQueue instance.
    /// If the database cannot be created or accessed, it logs an error and returns nil.
    /// - Parameters:
    ///   - dbName: The name of the database file to locate and open.
    /// - Returns: An optional `DatabaseQueue` instance. If successful, the queue is returned; otherwise, nil is returned.
    private func getWritableDatabaseQueue(by dbName: String) -> DatabaseQueue? {
        do {
            let dbUrl: URL = {
                let fileManager = FileManager.default
                let appSupportUrl = try! fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                return appSupportUrl.appendingPathComponent(dbName)
            }()
            
            return try DatabaseQueue(path: dbUrl.path)
        } catch {
            print("Error creating database queue from \(dbName): \(error)")
            return nil
        }
    }
    
    enum DatabaseManagerError : Error {
        case notFound(String)
    }
}
