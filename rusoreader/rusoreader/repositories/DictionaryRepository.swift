import GRDB
import Foundation

// A repository for grabbing, adding, and managing words that user has clicked on and previously studied in exercises
class DictionaryRepository {
    let databaseManager: DatabaseManager

    init(databaseManager: DatabaseManager) {
        self.databaseManager = databaseManager
    }

    /// The total number of entries added to the dictionary
    var count: Int {
        do {
            return try databaseManager.userDataQueue.read { db in
                return try DatabaseDictionaryWord.fetchAll(db).count
            }
        } catch {
            return 0
        }
    }


    /// Add the word's id to the dictionary, if it's already in the dictionary we will increase the times clicked and possibly increase the repetition score if clicked more than 3 times
    /// - Parameters:
    ///   - wordId: The ID of the word clicked, must be the ID from the standard Word dictionary
    ///   - score: Set initial score, defaults to 3.0
    ///   - timesClicked: Set the inital times clicked, defaults to 1
    ///   - timesAppeared: Set the times the user has encountered the word in exercises, defaults to 0
    ///   - firstSeen: Set the first time the user clicked on the word, defaults to todays date
    ///   - lastSeen: Set the last time the user has seen the word word in exercises or clicking on, defaults to todays date
    ///   - dueDate: Set the date the spaced repetition algorithim will choose the word, defaults to tomorrows date
    func addWord(by wordId: Int,
        score: Double = 3.0,
        timesClicked: Int = 1,
        timesAppeared: Int = 0,
        firstSeen: Date = Date.now,
        lastSeen: Date = Date.now,
        dueDate: Date = Date.now + TimeInterval(60 * 60 * 24) // This adds one day initially
    ) {
        do {
            if wordId <= 0 {
                return
            }

            try databaseManager.userDataQueue.write { db in
                if var previousEntry = try getDatabaseEntry(by: Int64(wordId), from: db) {
                    previousEntry.times_clicked += 1
                    previousEntry.last_seen = Date.now
                    if previousEntry.times_clicked > 3 {
                        previousEntry.score += 1.0
                    }
                    try previousEntry.update(db)
                } else {
                    var newEntry = DatabaseDictionaryWord(
                        id: Int64(wordId),
                        score: score,
                        times_clicked: Int64(timesClicked),
                        times_appeared: Int64(timesAppeared),
                        first_seen: firstSeen,
                        last_seen: lastSeen,
                        due_date: dueDate
                    )
                    try newEntry.insert(db)
                }
            }
        } catch {
            print("Error: \(error)")
        }
    }

    /// Find the word in the dictionary based upon its ID
    /// - Parameter wordId: The id of the word we are searching for
    /// - Returns: A dictionary entry based upon the word id, if the ID doesn't exisit in the dictionary this will return nil
    func find(by wordId: Int) -> DictionaryEntry? {
        do {
            return try databaseManager.userDataQueue.read { db in
                if let dbEntry = try getDatabaseEntry(by: Int64(wordId), from: db) {
                    return DictionaryEntry(
                        wordId: Int(dbEntry.id),
                        firstSeen: dbEntry.first_seen,
                        lastSeen: dbEntry.last_seen,
                        dueForReview: dbEntry.due_date,
                        score: Float(dbEntry.score),
                        timesClicked: Int(dbEntry.times_clicked),
                        timesAppeared: Int(dbEntry.times_appeared)
                    )
                }
                return nil
            }
        } catch {
            return nil
        }
    }

    /// Returns every entry found in the dictionary regardless of any score or dates
    /// - Returns: Every entry in the database
    func getAll() -> [DictionaryEntry] {
        do {
            return try databaseManager.userDataQueue.read { db in
                return try DatabaseDictionaryWord.fetchAll(db).map { dbEntry in
                    return DictionaryEntry(
                        wordId: Int(dbEntry.id),
                        firstSeen: dbEntry.first_seen,
                        lastSeen: dbEntry.last_seen,
                        dueForReview: dbEntry.due_date,
                        score: Float(dbEntry.score),
                        timesClicked: Int(dbEntry.times_clicked),
                        timesAppeared: Int(dbEntry.times_appeared)
                    )
                }
            }
        } catch {
            print("Error: \(error)")
            return []
        }
    }

    func getNeverBeforeSeenWords(limit: Int = 5) -> [DictionaryEntry] {
        do {
            return try databaseManager.userDataQueue.read { db in
                let neverSeenWords = try DatabaseDictionaryWord.fetchAll(db).compactMap { dbEntry in
                    return dbEntry.times_appeared == 0
                        ? DictionaryEntry(
                            wordId: Int(dbEntry.id),
                            firstSeen: dbEntry.first_seen,
                            lastSeen: dbEntry.last_seen,
                            dueForReview: dbEntry.due_date,
                            score: Float(dbEntry.score),
                            timesClicked: Int(dbEntry.times_clicked),
                            timesAppeared: Int(dbEntry.times_appeared))
                        : nil
                }
                let returnCount = min(neverSeenWords.count, limit);
                return Array(neverSeenWords.shuffled()[0..<returnCount])
            }
        } catch {
            print("Error: \(error)")
            return []
        }
    }

    func getAllDueWords() -> [DictionaryEntry] {
        do {
            return try databaseManager.userDataQueue.read { db in
                return try DatabaseDictionaryWord.fetchAll(db).compactMap { dbEntry in
                    return dbEntry.due_date < Date.now
                        ? DictionaryEntry(
                            wordId: Int(dbEntry.id),
                            firstSeen: dbEntry.first_seen,
                            lastSeen: dbEntry.last_seen,
                            dueForReview: dbEntry.due_date,
                            score: Float(dbEntry.score),
                            timesClicked: Int(dbEntry.times_clicked),
                            timesAppeared: Int(dbEntry.times_appeared))
                        : nil
                }
            }
        } catch {
            print("Error: \(error)")
            return []
        }
    }

    /// Remove all entries from the database, will mostly be used for testing purposes
    func clear() {
        do {
            try databaseManager.userDataQueue.write { db in
                let entries = try DatabaseDictionaryWord.fetchAll(db)

                for entry in entries {
                    try entry.delete(db)
                }
            }
        } catch {
            print("Error: \(error)")
        }
    }

    func updateScore(for wordId: Int, by amount: Double) {
        do {
            try databaseManager.userDataQueue.write { db in
                if var entry = try getDatabaseEntry(by: Int64(wordId), from: db) {
                    entry.score = max(0.0, entry.score + amount)
                    try entry.update(db)
                }
            }
        } catch {
            print("Error: \(error)")
        }
    }

    func update(word: Word, scoreChangeAmount: Double = 0, newDueDate: Date = Date.now + TimeInterval(60 * 60 * 24)) {
        do {
            try databaseManager.userDataQueue.write { db in
                if var entry = try getDatabaseEntry(by: Int64(word.id), from: db) {
                    entry.score = max(0.0, entry.score + scoreChangeAmount)
                    entry.due_date = newDueDate
                    try entry.update(db)
                }
            }
        } catch {
            print("Error: \(error)")
        }
    }

    private func getDatabaseEntry(by wordId: Int64, from db: Database) throws -> DatabaseDictionaryWord? {
        return try DatabaseDictionaryWord.fetchOne(db, id: wordId)
    }

    private func getEntry(by wordId: Int64, from db: Database) throws -> DictionaryEntry? {
        if let dbEntry = try DatabaseDictionaryWord.fetchOne(db, id: wordId) {
            return DictionaryEntry(
                wordId: Int(dbEntry.id),
                firstSeen: dbEntry.first_seen,
                lastSeen: dbEntry.last_seen,
                dueForReview: dbEntry.due_date,
                score: Float(dbEntry.score),
                timesClicked: 1,
                timesAppeared: 0
            )
        }
        return nil
    }

    private func isWordAdded(by wordId: Int64, from db: Database) throws -> Bool {
        if let _ = try DatabaseDictionaryWord.fetchOne(db, id: wordId) {
            return true
        }
        return false
    }
}
