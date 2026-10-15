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
    
    /// The top 3 translations for a word in a formatted string
    var translationText: String {
        var text = ""
        var i = 0
        let max = 3 // We will avoid anything over the third translation as it may begin to cause formatting issues
        
        for translation in translations {
            if i < max {
                text.append("\(translation)\n")
            } else {
                break
            }
            
            i += 1
        }
        
        // Remove the last new line character from the string
        if !text.isEmpty {
            text.removeLast()
        }
        
        return text
    }
    
    /// The very first translation, if translation is seperated by commas then tranlsation before first comma will be returned. Will return blank if any nil values are hit
    var firstTranslation: String {
        guard let first = translations.first else { return "" }
        return String(first.split(separator: ",").first ?? "")
    }
    
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
