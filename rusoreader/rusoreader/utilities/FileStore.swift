import Foundation
import UIKit

final class FileStore {
    let directory: URL
    
    init(directory: URL? = nil) {
        // If there isn't a suppled directory URL we will set it as the documents directory by default
        if let dir = directory {
            self.directory = dir
        } else {
            guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                fatalError("Document Directory not found")
            }
            
            self.directory = documentDirectory
        }
    }
    
    func save(data: Data, fileName: String) throws {
        let fileURL = directory.appendingPathComponent(fileName)
        try data.write(to: fileURL)
    }
    
    func load(fileName: String) throws -> Data {
        let fileUrl = directory.appendingPathComponent(fileName)
        return try Data(contentsOf: fileUrl)
    }
    
    func deleteItem(fileName: String) throws {
        let fileUrl = directory.appendingPathComponent(fileName)
        let fileManager = FileManager()
        try fileManager.removeItem(at: fileUrl)
    }
}
