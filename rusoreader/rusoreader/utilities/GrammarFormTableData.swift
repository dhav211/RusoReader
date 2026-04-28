struct GrammarFormTableData {
    enum TableType {
        case adjective
        case noun
        case verb
        case verbPast
        case verbImperative
        case verbParticiples
    }
    
    struct Cell {
        let text: String
        let isRussianWord: Bool
        
        init(text: String, isRussianWord: Bool) {
            self.text = text
            self.isRussianWord = isRussianWord
        }
    }
    
    let forms: [[Cell]]
    
    init(wordForms: [String:String], grammarTableType: TableType) {
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
                        Cell(text: wordForms["ru_noun_sg_nom"] ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_noun_pl_nom"] ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "Genitive", isRussianWord: false),
                         Cell(text: wordForms["ru_noun_sg_gen"] ?? "", isRussianWord: true),
                         Cell(text: wordForms["ru_noun_pl_gen"] ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "Genitive", isRussianWord: false),
                        Cell(text: wordForms["ru_noun_sg_dat"] ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_noun_pl_dat"] ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "Accusative", isRussianWord: false),
                        Cell(text: wordForms["ru_noun_sg_acc"] ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_noun_pl_acc"] ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "Instrumental", isRussianWord: false),
                        Cell(text: wordForms["ru_noun_sg_inst"] ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_noun_pl_inst"] ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "Prepositional", isRussianWord: false),
                        Cell(text: wordForms["ru_noun_sg_prep"] ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_noun_pl_prep"] ?? "", isRussianWord: true)
                    ]
                ]
            case .verbPast:
                return [
                    [
                        Cell(text: "Masculine", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_past_m"] ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "Feminine", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_past_f"] ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "Neuter", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_past_n"] ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "Plural", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_past_pl"] ?? "", isRussianWord: true)
                    ]
                ]
            case .verb:
                return [
                    [
                        Cell(text: "я", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_presfut_sg1"] ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "ты", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_presfut_sg2"] ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "он/она/оно", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_presfut_sg3"] ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "мы", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_presfut_pl1"] ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "вы", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_presfut_pl2"] ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "они", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_presfut_pl3"] ?? "", isRussianWord: true)
                    ],
                ]
            case .verbImperative:
                return [
                    [
                        Cell(text: "ты", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_imperative_sg"] ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "вы", isRussianWord: false),
                        Cell(text: wordForms["ru_verb_imperative_pl"] ?? "", isRussianWord: true)
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
                        Cell(text: wordForms["ru_adj_m_nom"] ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_adj_f_nom"] ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_adj_n_nom"] ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_adj_pl_nom"] ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "Gen", isRussianWord: false),
                        Cell(text: wordForms["ru_adj_m_gen"] ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_adj_f_gen"] ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_adj_n_gen"] ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_adj_pl_gen"] ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "Dat", isRussianWord: false),
                        Cell(text: wordForms["ru_adj_m_dat"] ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_adj_f_dat"] ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_adj_n_dat"] ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_adj_pl_dat"] ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "Acc", isRussianWord: false),
                        Cell(text: wordForms["ru_adj_m_acc"] ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_adj_f_acc"] ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_adj_n_acc"] ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_adj_pl_acc"] ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "Inst", isRussianWord: false),
                        Cell(text: wordForms["ru_adj_m_inst"] ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_adj_f_inst"] ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_adj_n_inst"] ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_adj_pl_inst"] ?? "", isRussianWord: true)
                    ],
                    [
                        Cell(text: "Prep", isRussianWord: false),
                        Cell(text: wordForms["ru_adj_m_prep"] ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_adj_f_prep"] ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_adj_n_prep"] ?? "", isRussianWord: true),
                        Cell(text: wordForms["ru_adj_pl_prep"] ?? "", isRussianWord: true)
                    ]
                ]
            default:
                return [[Cell(text:"", isRussianWord: false)]]
            }
        }()
    }
}
