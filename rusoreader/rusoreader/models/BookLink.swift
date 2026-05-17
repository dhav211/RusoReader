import Foundation
import GRDB

/// Creates a connection between the BookSelector and the book, so all the data of the book doesn't need to be loaded for the selector
struct BookLink  {
    let bookId: Int
    let title: String
    let author: String
    let coverImageURL: String
}
