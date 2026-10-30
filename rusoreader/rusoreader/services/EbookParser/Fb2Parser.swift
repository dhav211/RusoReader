import Foundation

enum FB2ParsingError : Error {
    case fileNotExists(url: String)
    case failedToParse
    case notRussian
}

final class Fb2Parser: EbookParser {
    func parse(from bookUrl: URL) throws -> ParsedBook {
        let parser = XMLParser(contentsOf: bookUrl)
        let delegate = XMLBookParser()
        parser?.delegate = delegate
        
        if let parser, parser.parse() {
            return delegate.createParsedBook()
        } else {
            throw FB2ParsingError.failedToParse
        }
    }
    
    private final class XMLBookParser: NSObject, XMLParserDelegate {
        private struct FB2Author {
            var firstName: String = ""
            var lastName: String = ""
        }
        
        private struct FB2Chapter {
            var title: String? = nil
            var text: String = ""
            var isTitleSet: Bool = false
        }
        
        private struct FB2CoverImage {
            var imageName: String? = nil
            var fileType: String? = nil
            var data: Data? = nil
        }
        
        private var currentAuthor: FB2Author? = nil
        private var authors = [FB2Author]()
        private var title: String? = nil
        private var isbn: String? = nil
        private var uuid: String? = nil
        private var language: String? = nil
        private var chapters = [ChapterDetails]()
        private var currentChapter: FB2Chapter? = nil
        private var coverImage: FB2CoverImage? = nil
        
        private var chapterIndex = 0
        private var text = ""
        
        func createParsedBook() -> ParsedBook {
            let bookAuthor: String = {
                var a = String()
                for i in 0..<authors.count {
                    if authors[i].firstName.isEmpty && authors[i].lastName.isEmpty {
                        continue
                    }
                    
                    if i > 0 {
                        a.append(", ")
                    }
                    a.append("\(authors[i].firstName) \(authors[i].lastName)")
                }
                
                return a
            }()
            
            var bookDetails = BookDetails(title: title ?? "", author: bookAuthor, isbn: "", uuid: uuid ?? "", language: language ?? "")
            bookDetails.coverImage = coverImage?.data
            bookDetails.coverImageFileType = coverImage?.fileType ?? ""
            
            return ParsedBook(book: bookDetails, chapters: chapters)
        }
        
        func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
            switch elementName {
            case "book-title":
                if title == nil {
                    title = String()
                }
            case "id":
                uuid = String()
            case "author":
                currentAuthor = FB2Author()
            case "lang":
                if language == nil {
                    language = String()
                }
            case "coverpage":
                coverImage = FB2CoverImage()
            case "image":
                // In our reading we are only picking up the cover image, so if the cover image path is nil then we can set the image, however if another image comes up, we will just ignore it
                if coverImage == nil { break }
                if coverImage?.imageName == nil {
                    var imageName = attributeDict["l:href"] ?? ""
                    if imageName.hasPrefix("#") {
                        imageName.removeFirst()
                    }
                    
                    if !imageName.isEmpty {
                        coverImage?.imageName = imageName
                    }
                }
            case "section": // A new chapter has begun
                currentChapter = FB2Chapter()
            case "title": // The chapter's title is about to be created
                if currentChapter == nil { break }
                currentChapter?.title = String()
            case "binary":
                if attributeDict["id"] == coverImage?.imageName {
                    coverImage?.fileType = {
                        let contentType = attributeDict["content-type"]
                        
                        switch contentType?.lowercased() {
                        case "image/jpeg", "image/jpg":
                            return "jpg"
                        case "image/png":
                            return "png"
                        case "image/gif":
                            return "gif"
                        default:
                            return "bin"
                        }
                    }()
                }
            default:
                break
            }
        }
        
        func parser(_ parser: XMLParser, foundCharacters string: String) {
            text.append(string) // Full text doesn't always happen, so continue to append the text until end of tag
        }
        
        func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            text = text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            switch elementName {
            case "book-title":
                if let title, !title.isEmpty { break }
                title? = text
            case "id":
                uuid? = text
            case "first-name":
                currentAuthor?.firstName = text
            case "last-name":
                currentAuthor?.lastName = text
            case "author":
                if let currentAuthor {
                    authors.append(currentAuthor)
                }
                currentAuthor = nil
            case "lang":
                if let language, !language.isEmpty { break }
                language? = text
            case "section":
                if let currentChapter {
                    chapters.append(ChapterDetails(index: chapterIndex, title: currentChapter.title ?? "", text: currentChapter.text))
                }
                currentChapter = nil
                chapterIndex += 1
            case "title":
                currentChapter?.isTitleSet = true
            case "p":
                guard let isTitleSet = currentChapter?.isTitleSet else { break }
                guard let isTitleEmpty = currentChapter?.title?.isEmpty else { break }
                
                if isTitleSet {
                    currentChapter?.text.append("\(text)\n")
                } else if currentChapter?.title != nil {
                    if !isTitleEmpty {
                        currentChapter?.title?.append(" - ")
                    }
                    currentChapter?.title?.append(text)
                }
            case "binary":
                if coverImage?.data != nil { break }
                coverImage?.data = Data(base64Encoded: text, options: .ignoreUnknownCharacters)
            default:
                break
            }
            
            // Clear the text at the end of the tag so we can begin fresh on the next tag
            text = ""
        }
    }
}
