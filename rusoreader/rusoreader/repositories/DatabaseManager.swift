import GRDB
import UIKit
import Foundation
final class DatabaseManager {
    private(set) var queue: DatabaseQueue!
    
    init() {
        do {
            if let url = Bundle.main.url(forResource: "words", withExtension: "db") {
                queue = try DatabaseQueue(path: url.path())
            }
        } catch {
            fatalError("Failed to initialize the database")
        }
    }
}
