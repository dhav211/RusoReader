import Foundation

protocol EbookParser {
    func parse(from bookUrl: URL) -> ParsedBook?
}
