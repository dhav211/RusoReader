import GRDB

struct AppDatabase {
    let queue: DatabaseQueue!
    
    init(queue: DatabaseQueue!) {
        self.queue = queue
    }
    
    func runMigrations() {
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
            try migrator.migrate(queue)
        } catch {
            print("Failed to run migrations: \(error)")
        }
    }
}
