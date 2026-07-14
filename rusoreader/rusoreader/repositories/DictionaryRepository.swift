import GRDB
import Foundation

/// A repository that manages user dictionary entries in a local database.
///
/// `DictionaryRepository` provides methods to track words that users interact with,
/// maintaining statistics such as how many times a word has been clicked, when it was
/// first and last seen, and a scoring system for spaced repetition learning.
///
/// The repository persists data using GRDB and manages the following information for each word:
/// - Word ID (references the main word dictionary)
/// - Score (for spaced repetition algorithm)
/// - Times clicked (how often the user has looked up this word)
/// - Times appeared (how often the word has been encountered)
/// - First seen date
/// - Last seen date
/// - Due date for review
///
/// ## Topics
///
/// ### Initialization
/// - ``init(databaseManager:)``
///
/// ### Querying Dictionary Entries
/// - ``count``
/// - ``find(by:)``
/// - ``getAll()``
///
/// ### Managing Dictionary Entries
/// - ``addWord(by:)``
/// - ``clear()``
///
/// ### Private Helper Methods
/// - ``getDatabaseEntry(by:from:)``
/// - ``getEntry(by:from:)``
/// - ``isWordAdded(by:from:)``
/// - ``increaseTimesClicked(for:from:)``
/// - ``increaseScore(for:from:)``
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
    /// - Parameter wordId: The ID of the word clicked, must be the ID from the standard Word dictionary
    func addWord(by wordId: Int) {
        do {
            if wordId <= 0 {
                return
            }
            
            try databaseManager.userDataQueue.write { db in
                if var previousEntry = try getDatabaseEntry(by: Int64(wordId), from: db) {
                    previousEntry.times_clicked += 1
                    if previousEntry.times_clicked > 3 {
                        previousEntry.score += 1.0
                    }
                    try previousEntry.update(db)
                } else {
                    var newEntry = DatabaseDictionaryWord(
                        id: Int64(wordId),
                        score: 3.0,
                        times_clicked: 1,
                        times_appeared: 0,
                        first_seen: Date.now,
                        last_seen: Date.now
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
                    entry.score += amount
                    
                    if entry.score < 0 { entry.score = 0 }
                    
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
