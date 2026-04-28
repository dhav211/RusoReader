import GRDB

struct FetchedWordInfo: Decodable, FetchableRecord {
    let word: DatabaseWord
    let verb: DatabaseVerb?
    let noun: DatabaseNoun?
    let wordForms: [DatabaseWordForm]
    let translations: [DatabaseTranslation]
}
