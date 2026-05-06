import Foundation
import SwiftSoup
import ZIPFoundation

class EpubParser {
    init(bookUrl: URL) {
        let fileManager = FileManager()
        if fileManager.fileExists(atPath: bookUrl.path) {
            do {
                let archive = try Archive(url: bookUrl, accessMode: .read)
                guard let content = archive["META-INF/container.xml"] else { return }
                var contentData = Data()
                try archive.extract(content) { chuck in
                    contentData.append(chuck)
                }
                
                let contentString = String(data: contentData, encoding: .utf8)
                print(contentString)
            } catch EpubParserError.failedToUnzip {
                print("Error unzipping epub!")
            } catch {
                print("\(error)")
            }
        }
    }
    
    /*
     1 - get to content.opf file path from the META-INFA/container.xml file
     2 - Go through this file and it should give you all the information you need to create the book model to save to the database
     3 - save the cover image in app directory somewhere, this will be saved to the book model
     4 - At this point we will need to see if we can save to the database and get an id for chapter creation
     */
}
