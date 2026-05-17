import Foundation
import UIKit

final class FileStore {
    let directory: URL
    
    init(directory: URL) {
        self.directory = directory
    }
    
    func save(data: Data, fileName: String) throws {
        let fileURL = directory.appendingPathComponent(fileName)
        try data.write(to: fileURL)
    }
    
    func load(fileName: String) throws -> Data {
        do {
            let fileUrl = directory.appendingPathComponent(fileName)
            return try Data(contentsOf: fileUrl)
        } catch {
            throw FileStoreError.loadingError
        }
    }
    
    func deleteItem(fileName: String) throws {
        do {
            let fileUrl = directory.appendingPathComponent(fileName)
            let fileManager = FileManager()
            try fileManager.removeItem(at: fileUrl)
        } catch {
            throw FileStoreError.deletionError
        }
    }    
}

enum FileStoreError : Error {
    case savingError(message: String)
    case loadingError
    case deletionError
}
