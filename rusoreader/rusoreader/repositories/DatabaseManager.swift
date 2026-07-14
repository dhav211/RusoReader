import GRDB
import UIKit
import Foundation
final class DatabaseManager {
    private(set) var wordQueue: DatabaseQueue!
    private(set) var userDataQueue: DatabaseQueue!
    
    init(userDataQueue: DatabaseQueue?) {
        do {
            // The words DB is read-only so we can just grab it from the app bundle
            if let wordDatabaseUrl = Bundle.main.url(forResource: "words", withExtension: "db") {
                self.wordQueue = try DatabaseQueue(path: wordDatabaseUrl.path())
            }
            print(self.wordQueue.path)
            if let queue = userDataQueue {
                self.userDataQueue = queue
                print(self.userDataQueue.path)
                runUserDataMigrations(on: self.userDataQueue)
            }
        } catch {
            fatalError("Failed to initialize the database: \(error)")
        }
    }
    
    /// Instantiate the user data database queue by either accessing or creating a new one in the applications sandbox
    convenience init() {
        do {
            let dbUrl: URL = {
                let fileManager = FileManager.default
                let appSupportUrl = try! fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                return appSupportUrl.appendingPathComponent("user_data.db")
            }()
            self.init(userDataQueue: try DatabaseQueue(path: dbUrl.path))
        } catch {
            self.init(userDataQueue: nil)
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
    
    private func runUserDataMigrations(on queue: DatabaseQueue) {
        do {
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
            
            migrator.registerMigration("add url to chapter") { db in
                try db.alter(table: "chapters") { chaptersTable in
                    chaptersTable.add(column: "url", .text)
                }
            }
            
            migrator.registerMigration("set book_id as foreign key in chapter") { db in
                try db.drop(table: "chapters")
                try db.create(table: "chapters") { chaptersTable in
                    chaptersTable.primaryKey("id", .integer)
                    chaptersTable.column("name", .text)
                    chaptersTable.column("index", .integer)
                    chaptersTable.column("current_user_progress", .integer)
                    chaptersTable.column("text", .text)
                    chaptersTable.column("book_id", .integer)
                    
                    chaptersTable.foreignKey(["book_id"], references: "books", columns: ["id"], onDelete: .cascade)
                }
            }
            
            migrator.registerMigration("remove file url from book") { db in
                try db.alter(table: "books") { booksTable in
                    booksTable.drop(column: "file_url")
                }
            }
            
            migrator.registerMigration("add author to books") { db in
                try db.alter(table: "books") { booksTable in
                    booksTable.add(column: "author", .text)
                }
            }
            
            migrator.registerMigration("change chapter index to position") { db in
                try db.alter(table: "chapters") { chaptersTable in
                    chaptersTable.rename(column: "index", to: "position")
                }
            }
            
            migrator.registerMigration("create dictionary") { db in
                try db.create(table: "user_dictionary") { dictionaryTable in
                    dictionaryTable.primaryKey("id", .integer)
                    dictionaryTable.column("score", .integer).notNull()
                    dictionaryTable.column("first_seen", .date).notNull()
                    dictionaryTable.column("last_seen", .date).notNull()
                    dictionaryTable.column("due_date", .date)
                }
            }
            
            migrator.registerMigration("adds times clicked and times appeared") { db in
                try db.alter(table: "user_dictionary") { dictionaryTable in
                    dictionaryTable.add(column: "times_clicked", .integer).notNull()
                    dictionaryTable.add(column: "times_appeared", .integer).notNull()
                }
            }
            
            migrator.registerMigration("change score to float") { db in
                try db.alter(table: "user_dictionary") { dictionaryTable in
                    dictionaryTable.drop(column: "score")
                    dictionaryTable.add(column: "score", .double).notNull()
                }
            }
            
            try migrator.migrate(queue)
        } catch {
            print("Failed to run migrations on UserData DB: \(error)")
        }
    }
}
