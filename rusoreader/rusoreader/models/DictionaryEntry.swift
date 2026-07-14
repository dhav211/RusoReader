import Foundation

struct DictionaryEntry {
    let wordId: Int
    let firstSeen: Date
    let lastSeen: Date
    let dueForReview: Date?
    let score: Float
    let timesClicked: Int
    let timesAppeared: Int
}
