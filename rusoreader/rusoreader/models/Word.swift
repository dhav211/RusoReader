struct Word {
    let id: Int
    let bare: String
    let accented: String
    let type: WordType
    let level: String
    let ranking: Int
    let noun: Noun?
    let verb: Verb?
    let forms: [WordForm]
    let translations: [String]
    
    init(id: Int, bare: String, accented: String, type: WordType, level: String, ranking: Int, noun: Noun?, verb: Verb?, forms: [WordForm], translations: [String]) {
        self.id = id
        self.bare = bare
        self.accented = accented
        self.type = type
        self.level = level
        self.ranking = ranking
        self.noun = noun
        self.verb = verb
        self.forms = forms
        self.translations = translations
    }
    
    init() {
        self.id = 0
        self.bare = ""
        self.accented = ""
        self.type = .other
        self.level = ""
        self.ranking = 0
        self.noun = nil
        self.verb = nil
        self.forms = [WordForm]()
        self.translations = [String]()
    }
    
    enum WordType : String {
        case noun = "noun"
        case verb = "verb"
        case adjective = "adjective"
        case other = "other"
        case adverb = "adverb"
    }
}
