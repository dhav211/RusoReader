/// Grammar form table data structure for displaying linguistic inflection tables.
///
/// This struct encapsulates complete grammatical form data for Russian nouns, verbs, and adjectives,
/// organizing them into tabular cell layouts. Each cell contains text content with a flag indicating
/// whether it represents an actual Russian word or is structural/metadata content.
struct GrammarFormTableData {
    enum TableType {
        case adjective
        case noun
        case verbPresent
        case verbFuture
        case verbPast
        case verbImperative
        case verbParticiples
    }
    
    struct Cell {
        let text: String
        let isRussianWord: Bool
        let isAdjective: Bool
        
        init(text: String, isRussianWord: Bool, isAdjective: Bool = false) {
            self.text = text
            self.isRussianWord = isRussianWord
            self.isAdjective = isAdjective
        }
    }
    
    let forms: [[Cell]]
    
    /// Creates a grammar form table populated with cells based on the specified table type.
    ///
    /// - Parameters:
    ///     - wordForms: A dictionary mapping grammar form keys to their corresponding text values.
    ///     - grammarTableType: The type of grammatical table to generate (noun, verb, adjective, etc.).
    init(wordForms: [String:WordForm], grammarTableType: TableType) {
        self.forms = {
            switch(grammarTableType) {
            case .noun:
                return [
                    [
                        Cell(text: "", isRussianWord: false),
                        Cell(text: "Singular", isRussianWord: false),
                        Cell(text: "Plural", isRussianWord: false)
                    ],
                    [
                        Cell(text: "Nominative", isRussianWord: false),
                        Cell(text: wordForms["ru_noun_sg_nom"]?.accented ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_noun_pl_nom"]?.accented ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "Genitive", isRussianWord: false),
                         Cell(text: wordForms["ru_noun_sg_gen"]?.accented ?? "", isRussianWord: true),
                         Cell(text: wordForms["ru_noun_pl_gen"]?.accented ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "Dative", isRussianWord: false),
                        Cell(text: wordForms["ru_noun_sg_dat"]?.accented ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_noun_pl_dat"]?.accented ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "Accusative", isRussianWord: false),
                        Cell(text: wordForms["ru_noun_sg_acc"]?.accented ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_noun_pl_acc"]?.accented ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "Instrumental", isRussianWord: false),
                        Cell(text: wordForms["ru_noun_sg_inst"]?.accented ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_noun_pl_inst"]?.accented ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "Prepositional", isRussianWord: false),
                        Cell(text: wordForms["ru_noun_sg_prep"]?.accented ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_noun_pl_prep"]?.accented ?? "", isRussianWord: true)
                    ]
                ]
            case .verbPast:
                return [
                    [
                        Cell(text: "Past", isRussianWord: false)
                    ],
                    [
                        Cell(text: "Masculine", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_past_m"]?.accented ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "Feminine", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_past_f"]?.accented ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "Neuter", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_past_n"]?.accented ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "Plural", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_past_pl"]?.accented ?? "", isRussianWord: true)
                    ]
                ]
            case .verbPresent:
                return [
                    [
                        Cell(text: "Present", isRussianWord: false),
                    ],
                    [
                        Cell(text: "я", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_presfut_sg1"]?.accented ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "ты", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_presfut_sg2"]?.accented ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "он/она/оно", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_presfut_sg3"]?.accented ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "мы", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_presfut_pl1"]?.accented ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "вы", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_presfut_pl2"]?.accented ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "они", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_presfut_pl3"]?.accented ?? "", isRussianWord: true)
                    ],
                ]
            case .verbFuture:
                return [
                    [
                        Cell(text: "Future", isRussianWord: false),
                    ],
                    [
                        Cell(text: "я", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_presfut_sg1"]?.accented ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "ты", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_presfut_sg2"]?.accented ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "он/она/оно", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_presfut_sg3"]?.accented ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "мы", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_presfut_pl1"]?.accented ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "вы", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_presfut_pl2"]?.accented ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "они", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_presfut_pl3"]?.accented ?? "", isRussianWord: true)
                    ],
                ]
            case .verbImperative:
                return [
                    [
                        Cell(text: "ты", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_imperative_sg"]?.accented ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "вы", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_imperative_pl"]?.accented ?? "", isRussianWord: true)
                    ]
                ]
            case .adjective:
                return [
                    [
                        Cell(text: "", isRussianWord: false),
                        Cell(text: "M", isRussianWord: false),
                        Cell(text: "F", isRussianWord: false),
                        Cell(text: "N", isRussianWord: false),
                        Cell(text: "P", isRussianWord: false)
                    ],
                    [
                        Cell(text: "Nom", isRussianWord: false),
                        Cell(text: wordForms["ru_adj_m_nom"]?.accented ?? "", isRussianWord: true, isAdjective: true),
                        Cell(text: wordForms["ru_adj_f_nom"]?.accented ?? "", isRussianWord: true, isAdjective: true),
                        Cell(text: wordForms["ru_adj_n_nom"]?.accented ?? "", isRussianWord: true, isAdjective: true),
                        Cell(text: wordForms["ru_adj_pl_nom"]?.accented ?? "", isRussianWord: true, isAdjective: true)
                    ],
                    [
                        Cell(text: "Gen", isRussianWord: false),
                        Cell(text: wordForms["ru_adj_m_gen"]?.accented ?? "", isRussianWord: true, isAdjective: true),
                        Cell(text: wordForms["ru_adj_f_gen"]?.accented ?? "", isRussianWord: true, isAdjective: true),
                        Cell(text: wordForms["ru_adj_n_gen"]?.accented ?? "", isRussianWord: true, isAdjective: true),
                        Cell(text: wordForms["ru_adj_pl_gen"]?.accented ?? "", isRussianWord: true, isAdjective: true)
                    ],
                    [
                        Cell(text: "Dat", isRussianWord: false),
                        Cell(text: wordForms["ru_adj_m_dat"]?.accented ?? "", isRussianWord: true, isAdjective: true),
                        Cell(text: wordForms["ru_adj_f_dat"]?.accented ?? "", isRussianWord: true, isAdjective: true),
                        Cell(text: wordForms["ru_adj_n_dat"]?.accented ?? "", isRussianWord: true, isAdjective: true),
                        Cell(text: wordForms["ru_adj_pl_dat"]?.accented ?? "", isRussianWord: true, isAdjective: true)
                    ],
                    [
                        Cell(text: "Acc", isRussianWord: false),
                        Cell(text: wordForms["ru_adj_m_acc"]?.accented ?? "", isRussianWord: true, isAdjective: true),
                        Cell(text: wordForms["ru_adj_f_acc"]?.accented ?? "", isRussianWord: true, isAdjective: true),
                        Cell(text: wordForms["ru_adj_n_acc"]?.accented ?? "", isRussianWord: true, isAdjective: true),
                        Cell(text: wordForms["ru_adj_pl_acc"]?.accented ?? "", isRussianWord: true, isAdjective: true)
                    ],
                    [
                        Cell(text: "Inst", isRussianWord: false),
                        Cell(text: wordForms["ru_adj_m_inst"]?.accented ?? "", isRussianWord: true, isAdjective: true),
                        Cell(text: wordForms["ru_adj_f_inst"]?.accented ?? "", isRussianWord: true, isAdjective: true),
                        Cell(text: wordForms["ru_adj_n_inst"]?.accented ?? "", isRussianWord: true, isAdjective: true),
                        Cell(text: wordForms["ru_adj_pl_inst"]?.accented ?? "", isRussianWord: true, isAdjective: true)
                    ],
                    [
                        Cell(text: "Prep", isRussianWord: false),
                        Cell(text: wordForms["ru_adj_m_prep"]?.accented ?? "", isRussianWord: true, isAdjective: true),
                        Cell(text: wordForms["ru_adj_f_prep"]?.accented ?? "", isRussianWord: true, isAdjective: true),
                        Cell(text: wordForms["ru_adj_n_prep"]?.accented ?? "", isRussianWord: true, isAdjective: true),
                        Cell(text: wordForms["ru_adj_pl_prep"]?.accented ?? "", isRussianWord: true, isAdjective: true)
                    ]
                ]
            default:
                return [[Cell(text:"", isRussianWord: false)]]
            }
        }()
    }
}
