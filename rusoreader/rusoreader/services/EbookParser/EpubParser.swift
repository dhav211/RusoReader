import Foundation
import SwiftSoup
import ZIPFoundation

final class EpubParser : EbookParser {
    
    enum EpubParsingError : Error {
        case fileNotExists(url: String)
        case failedToExtractContent(url: String)
        case failedToUnzip
        case failedToParse
        case failedToFindCoverImage(message: String)
        case noTableOfContents
        case notRussian
    }
    
    typealias CoverImageData = (data: Data, fileType: String)
    
    /// Parses an epub file from a given URL bath.
    /// - Parameter bookUrl: The path to epub you wish to parse, this will probably be from the document picker
    /// - Returns: A parsed book object is comprised of a book and chapters array, this will hold all the information need to store the book in the database
    func parse(from bookUrl: URL) throws -> ParsedBook {
        let fileManager = FileManager()
        if fileManager.fileExists(atPath: bookUrl.path) {
            // Establish the structure of the epub by getting the content path and foler
            let archive = try Archive(url: bookUrl, accessMode: .read)
            guard let containerXmlText = try extractText(from: archive, with: "META-INF/container.xml") else { throw EpubParsingError.failedToParse }
            let contentPath = getContentFilePath(in: containerXmlText)
            
            // throughout this function we will need the initial folder where the content file is held. Not only is the content file held there but just about every other piece of information required for the epub, such as images and the actual text contents of the chapters
            let contentFolderPath = {
                var path = ""

                // This epub doesn't really contain much of a directory structure, so return an empty string
                if !contentPath.contains("/") {
                    return ""
                }
                
                for char in contentPath {
                    path.append(char)
                    if char == "/" {
                        break;
                    }
                }
                return path
            }()
            
            // Once the content file path has been found we can get the actual text from it and begin getting information from the epub
            guard let contentText = try extractText(from: archive, with: contentPath) else { throw EpubParsingError.failedToParse }
            
            // The content file will hold all we need to know about the book, so we will parse it here and keep it in a BookDetails struct
            var bookDetails = try getBookDetails(from: contentText)
            
            // Although the location of the cover image is in the content file, lets first save it to the app and keep that url
            // The cover image may not exist though, so if it doesn't we will skip past it
            if let coverImageData = try extractCoverImage(from: archive, with: contentText, contentFolderPath: contentFolderPath) {
                bookDetails.coverImage = coverImageData.data
                bookDetails.coverImageFileType = coverImageData.fileType
            }
            
            let tocPath = try getTableOfContentsPath(in: contentText)
            guard let tocText = try extractText(from: archive, with: contentFolderPath + tocPath) else { throw EpubParsingError.noTableOfContents }
            let chapters = parseChapters(from: archive, tableOfContentsText: tocText, contentText: contentText, contentFolderPath: contentFolderPath)
            
            return ParsedBook(book: bookDetails, chapters: chapters)
        } else {
            throw EpubParsingError.fileNotExists(url: bookUrl.absoluteString)
        }
    }
    
    /// Extracts the text data from the archive with the given addresss in the epub archive
    /// - Parameters:
    ///   - archive: A zip foundation archive of the epub the user is trying to open
    ///   - entryUrl: String representation of the address in the epub file, ex: "OPS/content.opf"
    /// - Returns: The text which was contained in the file given by the entryURL
    private func extractText(from archive: Archive, with entryUrl: String) throws -> String? {
        if let contentData = extractData(from: archive, at: entryUrl) {
            return String(data: contentData, encoding: .utf8)
        } else {
            return nil
        }
    }
    
    /// Find the cover image in the epub, then save it to the apps directory so the user will be able to see it without parsing the epub
    /// - Parameters:
    ///   - archive: The zip foundation archive object for the epub we are parsing
    ///   - contentText: The extracted text of the Content file
    ///   - contentFolderPath: The folder path to the content file, may be OPS or OEBPS
    /// - Returns: The URL of where the cover image was save, or nil if there wasn't a cover image or there was an issue saving
    private func extractCoverImage(from archive: Archive, with contentText: String, contentFolderPath: String) throws -> CoverImageData? {
        do {
            let document = try SwiftSoup.parse(contentText);
            
            // TODO This will only work for EPUB2, we need to find an EPUB3 and make it work
            // In epub2 the cover image id is stored in the metatags, we can search through each metaTag and check if one of their names is cover
            guard let coverId = try {
                let metadata = try document.select("metadata")
                let metaTags = try metadata.select("meta")
                for metaTag in metaTags {
                    if metaTag.hasAttr("name") {
                        let nameAttribute = try metaTag.attr("name")
                        if nameAttribute == "cover" {
                            return try metaTag.attr("content")
                        }
                    }
                }
                return nil
            }() else { throw EpubParsingError.failedToFindCoverImage(message: "While locating cover id") }
            
            // once the id has been found, which seems to usually be id1, we can search through the item tags checking their id attribute
            // when we find the matching id the image url will be held in the href attribute
            // <item href="images/cover.jpg" media-type="image/jpeg" id="id1"/>
            guard let coverImagePath = try {
                let manifest = try document.select("manifest")
                let itemTags = try manifest.select("item")
                for itemTag in itemTags {
                    if itemTag.hasAttr("id") {
                        let idAttribute = try itemTag.attr("id")
                        if idAttribute == coverId {
                            return try itemTag.attr("href")
                        }
                    }
                }
                return nil
            }() else { throw EpubParsingError.failedToFindCoverImage(message: "While locating cover image path") }
            
            if let contentData = extractData(from: archive, at: contentFolderPath + coverImagePath),
               let filetype = coverImagePath.split(separator: ".").last {
                return (data: contentData, fileType: ".\(filetype)")
            }
        } catch EpubParsingError.failedToFindCoverImage(let message) {
            print("Error finding cover image url: \(message)")
        }
        return nil
    }
    
    /// Find every chapter text file in the content folder, this will be done by searching the table of contents. The chapter text file will contain all the paragraphs in the chapter which we will store as a string. In this implementation we ignore any sort of stylized text.
    /// - Parameters:
    ///   - archive: The zip foundation archive object for the epub we are parsing
    ///   - tableOfContentsText: A parsed version of the table of contents which will be used to search for the chapter text files
    ///   - contentText: The parsed version of the content.opf or whatever the epub chose to name the file, this will be used as backup for finding the changes if the toc.ncx is missing or empty
    ///   - contentFolderPath: We need the path to the content folder so we can successfully pull up the chapter text files to parse
    /// - Returns: An array of the chapters, which hold all the information of the chapter, which would be title, text, and index
    private func parseChapters(from archive: Archive, tableOfContentsText: String, contentText: String, contentFolderPath: String) -> [ChapterDetails] {
        do {
            var chapters = [String:ChapterDetails]()
            
            // There may be a chance there was no toc.ncx, so the navPoints may be nil all together
            let navPoints: Elements? = {
                do {
                    let parsedToc = try SwiftSoup.parse(tableOfContentsText)
                    return try parsedToc.getElementsByTag("navPoint")
                } catch {
                    return nil
                }
            }()
            
            // If the navPoints don't exist then we can parse the content file (ex: content.opf), however don't waste the energy to parse if not needed
            let parsedContent: Document? = {
                do {
                    if let navPoints, !navPoints.isEmpty() {
                        return nil
                    }
                    
                    return try SwiftSoup.parse(contentText)
                } catch {
                    return nil
                }
            }()
            
            // If the toc.ncx is missing or empty the navPoints will be nil, this will be our back up for finding the chapters
            let spine: Elements? = {
                do {
                    guard let parsedContent else { return nil }
                    guard let spine = try parsedContent.getElementsByTag("spine").first() else { return nil }
                    return spine.children()
                } catch {
                    return nil
                }
            }()
            
            var currentIndex = 0
            
            // This tuple will the information to find the
            typealias ChapterIndex = (title: String, path: String, id: String)
            var chapterIndices = [ChapterIndex]()
            
            if let navPoints, !navPoints.isEmpty() { // The toc.ncx file has pointers to the chapters
                for navPoint in navPoints {
                    guard let title = try navPoint.getElementsByTag("navLabel").first()?
                        .getElementsByTag("text").first()?
                        .text() else { continue }
                    
                    let pathWithId = try navPoint.getElementsByTag("content")
                        .first()?.attr("src")
                        .split(separator: "#")
                    
                    guard let chapterFileName = pathWithId?.first else { continue }
                    
                    let idPathCount = pathWithId?.count ?? 0
                    let idPath = idPathCount > 1 ? pathWithId?.last ?? "" : ""
                    
                    chapterIndices.append(ChapterIndex(title: title, path: String(chapterFileName), id: String(idPath)))
                }
            } else if let spine, let parsedContent { // The toc.ncx doesn't have pointers to the chapters so we need to use the spine in the content.opf
                let manifest = try parsedContent.getElementsByTag("manifest").first()
                let manifestItems = try manifest?.getElementsByTag("item")
                
                // The dictionary will be used for easy access of chapter file addresses, use the id as a key and the file adress as a value
                var chapterAddresses = [String:String]()
                
                guard let manifestItems else { return [ChapterDetails]() }
                
                // The manifest will contain the file address and id for each chapter however they will not be in order
                for manifestItem in manifestItems {
                    let chapterId = try manifestItem.attr("id")
                    let chapterHref = try manifestItem.attr("href")
                    
                    chapterAddresses[chapterId] = chapterHref
                }
                
                // To put the chapters in order will loop through the spine, which just contains the id
                var chapterIndex = 1
                
                // We are not so much concerned about chapters that aren't actually chapters, as this may be a whole thing to format that we aren't prepared for, lets just skip them
                let itemsToSkip = ["cover.xhtml", "titlepage.xhtml", "title.xhtml", "copyright.xhtml", "imprint.xhtml", "dedication.xhtml", "epigraph.xhtml", "toc.xhtml", "nav.xhtml", "contents.xhtml", "preface.xhtml", "foreword.xhtml", "introduction.xhtml", "annotation.xhtml", "afterword.xhtml", "acknowledgments.xhtml", "about.xhtml", "notes.xhtml", "footnotes.xhtml", "appendix.xhtml", "colophon.xhtml", "ads.xhtml"]
                
                // The items in the spine are in the correct order, however they will not contain the name of the chapter so we will have to just increment the chapter number, which may not always be correct
                for child in spine {
                    let idRef = try child.attr("idref")
                    let address = chapterAddresses[idRef]
                    
                    guard let address else { continue }
                    if itemsToSkip.contains(address) { continue }
                    
                    chapterIndices.append(ChapterIndex(title: "Chapter \(chapterIndex)", path: address, id: idRef))
                    
                    chapterIndex += 1
                }
            } else {
                return [ChapterDetails]()
            }
            
            // Finally we have the location and order of the chapter files, we can parse the text within the chapters and create the chapter objects
            for chapterIndex in chapterIndices {
                let chapterUrl = ("\(contentFolderPath)\(chapterIndex.path)")
                
                if !chapters.keys.contains(chapterUrl) {
                    guard let chapterText = try extractText(from: archive, with: chapterUrl) else { continue }
                    let parsedChapterText = try SwiftSoup.parse(chapterText)
                    guard let body = parsedChapterText.body() else { continue }
                    let text = try extractChapterText(from: body)

                    chapters[chapterUrl] = (ChapterDetails(index: currentIndex, title: chapterIndex.title, text: text))
                
                    currentIndex += 1
                }
            }
            return chapters.values.map { chapterDetail in
                return chapterDetail
            }
        } catch {
            print("\(error)")
            return [ChapterDetails]()
        }
    }
    
    /// Recursively walks an HTML element's child nodes to build the plain-text contents of a chapter
    /// - Parameter element: The root element (e.g. a chapter's body) whose text should be extracted
    /// - Returns: The concatenated text of the element, with `<br>` tags converted to newlines, block-level
    ///   tags (`p`, `div`) followed by a trailing newline, and heading/title tags skipped entirely
    private func extractChapterText(from element: Element) throws -> String {
        var result = ""
        for node in element.getChildNodes() {
            if let textNode = node as? TextNode {
                result += textNode.text().trimmingCharacters(in: .whitespacesAndNewlines)
            } else if let el = node as? Element {
                // For formatting reason ignore any tags that may indicate that it's a chapter title
                if ["h1", "h2", "h3", "title"].contains(el.tagName()) { continue }
                if el.tagName() == "br" {
                    result += "\n"
                } else {
                    // recurse into <span>, <div>, <i>, etc.
                    result += try extractChapterText(from: el).trimmingCharacters(in: .whitespacesAndNewlines)
                    if ["p", "div"].contains(el.tagName()) { result += "\n" }
                }
            }
        }
        return result
    }
    
    /// Extracts the data from the epub archive at the given path
    /// - Parameters:
    ///   - archive: The zip foundation archive of the epub
    ///   - path: The path within the epub we wish to extract
    /// - Returns: The usable data stored within the archive, can be used for text or images
    private func extractData(from archive: Archive, at path: String) -> Data? {
        do {
            if let content = archive[path] {
                var contentData = Data()
                let _ = try archive.extract(content) { chunk in
                    contentData.append(chunk)
                }
                return contentData
            }
            return nil
        } catch {
            print("Error extracting data: \(error)")
            return nil
        }
    }
    
    /// Find the path in the container.xml file to the content file, this could be in various folders it just depends on the epub itself. Typically found in a OPS folder.
    /// - Parameter containerXml: The container.xml file which is consistent in every epub file
    /// - Returns: The definitive path to the content file, which will be used to find the rest of the data in the epub. If not found, it will return an empty string, which should be highly unlikely as this is an epub standard.
    private func getContentFilePath(in containerXml: String) -> String {
        var contentPath = ""
        do {
            // The container.xml file should remain as consistent standard in epub files. We should always find the content file under the rootfile tag
            let document = try SwiftSoup.parse(containerXml)
            let rootfile = try document.select("rootfile")
            contentPath.append(try rootfile.attr("full-path"))
        } catch {
            // If this retuns an empty string then it is safe to assume the epub file itself is completely malformed
            return ""
        }
        
        return contentPath
    }
    
    private func getTableOfContentsPath(in contentText: String) throws -> String {
        do {
            let document = try SwiftSoup.parse(contentText)
            let tocId = try document.select("spine").attr("toc")
            let manifest = try document.select("manifest")
            let itemTags = try manifest.select("item")
            var tocPath = ""
            
            for item in itemTags {
                let itemId = try item.attr("id")
                if itemId == tocId {
                    tocPath = try item.attr("href")
                    break
                }
            }
            
            return tocPath
        } catch {
            print("Failed to find Table Of Contents because: \(error)")
            return ""
        }
    }
    
    /// Parse the content file path and extract the book details, such as title, author, etc.
    /// - Parameter contentText: The text contents of the content file
    /// - Returns: A BookDetails struct is a simple data object which holds information such as title, author, isbn and uuid. This will be used to create the database objects
    private func getBookDetails(from contentText: String) throws -> BookDetails {
        do {
            // parse the content file to find the tags that hold the identifying data for the epub file
            let document = try SwiftSoup.parse(contentText)
            let metadata = try document.select("metadata")
            let titleTag = try metadata.select("dc|title")
            let authorTag = try metadata.select("dc|creator")
            let identifierTags = try metadata.select("dc|identifier")
            let languageTag = try metadata.select("dc|language")
            
            // when parsing we were just left with objects that hold the details, the rest of this function will be grabbing the data in the objects and setting this as strings
            // we also have to provide a little defense so we don't hit an empty tag
            var title = "", author = "", isbn = "", uuid = "", language = ""
            
            if titleTag.hasText() {
                title = try titleTag.text()
            }
            if authorTag.hasText() {
                author = try authorTag.text()
            }
            if languageTag.hasText() {
                language = try languageTag.text()
            }
            
            // There may be multiple identifers found in the book, so we will cover both
            // in the content file the identifers will have a prefix of the sorts attached before it, so we will remove it and then leave the rest of the text as the identifer
            for id in identifierTags {
                if id.hasText() {
                    let idText = try id.text()
                    if idText.hasPrefix("urn:uuid:") {
                        uuid = "\(idText.dropFirst("urn:uuid:".count))"
                    } else if idText.hasPrefix("isbn:") {
                        isbn = "\(idText.dropFirst("isbn:".count))"
                    }
                }
            }
            
            return BookDetails(title: title, author: author, isbn: isbn, uuid: uuid, language: language)
        } catch {
            throw EpubParsingError.failedToParse
        }
    }
}
