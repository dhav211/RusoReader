import UIKit

class WordDetailsView: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let sampleNoun = createSampleNoun()
        
        //let scrollView = UIScrollView()
        let wordDetailsStack = UIStackView()
        wordDetailsStack.axis = .vertical
        wordDetailsStack.distribution = .fillProportionally
        wordDetailsStack.alignment = .center
        wordDetailsStack.translatesAutoresizingMaskIntoConstraints = false
        wordDetailsStack.spacing = 16
        view.addSubview(wordDetailsStack)

        wordDetailsStack.addArrangedSubview(createWordTitleHeader(for: sampleNoun.text))
        
        if let translationStack = createTranslationSection(with: sampleNoun.translations) {
            wordDetailsStack.addArrangedSubview(translationStack)
        }
        
        wordDetailsStack.addArrangedSubview(createWordInformation(for: sampleNoun))
        
        wordDetailsStack.addArrangedSubview(createNounDeclensionTable(with: sampleNoun.wordForms))
        
        NSLayoutConstraint.activate([
            wordDetailsStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            wordDetailsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            wordDetailsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0)
        ])
    }
    
    /// MARK Element Creation Methods
    
    /// Create the header for the details page, this will include the accented word and also a icon button which will add the word to the users dictionary
    private func createWordTitleHeader(for word: String) -> UIStackView {
        let wordStack = UIStackView()
        wordStack.axis = .horizontal
        wordStack.spacing = 32
        wordStack.setContentHuggingPriority(.defaultLow, for: .vertical)
        let wordLabel = UILabel()
        wordLabel.text = word
        wordStack.addArrangedSubview(wordLabel)
        // TODO the add to dictionary will need to handle tap recongization
        let bookImage = UIImage(systemName: "book")
        let addToDicView = UIImageView(image: bookImage)
        wordStack.addArrangedSubview(addToDicView)
        
        return wordStack
    }
    
    /// Creates the word's translations, which will be a group a labels set in a vertical stack. Can return nil if no translations exist for the word
    private func createTranslationSection(with translations: [String]) -> UIStackView? {
        if translations.isEmpty {
            return nil
        }
        
        let translationStack = UIStackView()
        translationStack.axis = .vertical
        let translationHeader = UILabel()
        translationHeader.text = "Translations"
        translationStack.addArrangedSubview(translationHeader)
        for translation in translations {
            let translationText = UILabel()
            translationText.text = "- " + translation
            translationStack.addArrangedSubview(translationText)
        }
        
        return translationStack
    }
    
    /// The word information will give the user details on the word just as it's word type, it's gender, and various other useful details on the word
    private func createWordInformation(for word: SampleNoun) -> UILabel { // TODO this shouldn't have a SampleNoun parameter,
        let informationLabel = UILabel()
        var information = word.wordType
        
        // TODO a lot of this will be changed once we get the database working, we will be using enums instead of strings here, but the logic will remain
        
        // The word information will change depending on if it's noun, verb, adjective
        switch word.wordType {
        case "noun":
            if word.gender == "f" {
                information.append(", female")
            } else if word.gender == "m" {
                information.append(", male")
            } else {
                information.append(", neuter")
            }
            
            if word.animate {
                information.append(", animate")
            } else {
                information.append(", inanimate")
            }
        default:
            print("Word doesn't have a word type!")
        }
        
        // The user wouldn't need to know the exact ranking of the word, so we can just give them a general idea what the ranking is
        if word.ranking >= 0 && word.ranking <= 10 {
            information.append(", Top 10")
        } else if word.ranking > 10 && word.ranking <= 100 {
            information.append(", Top 100")
        } else if word.ranking > 100 && word.ranking <= 10_000 {
            let rankingMultipler : Int = word.ranking / 500
            information.append(", Top \((rankingMultipler + 1) * 500)")
        } else if word.ranking > 10_000 && word.ranking <= 50_000 {
            let rankingMultipler : Int = word.ranking / 5000
            information.append(", Top \((rankingMultipler + 1) * 5000)")
        } else if word.ranking > 50_000 {
            information.append(", Very rarely used")
        }
        
        informationLabel.text = information
        return informationLabel
    }
    
    private func createNounDeclensionTable(with wordForms: [String:String]) -> UIStackView {
        let columnStack = UIStackView()
        columnStack.axis = .vertical
        columnStack.distribution = .fill
        columnStack.spacing = 4

        // TODO we should make a function that takes the wordForms and word type then returns the correct 2d array
        let cellTexts = [
            ["", "Singular", "Plural"],
            ["Nominative", wordForms["ru_noun_sg_nom"], wordForms["ru_noun_pl_nom"]],
            ["Genitive", wordForms["ru_noun_sg_gen"], wordForms["ru_noun_pl_gen"]],
            ["Dative", wordForms["ru_noun_sg_dat"], wordForms["ru_noun_pl_dat"]],
            ["Accusative", wordForms["ru_noun_sg_acc"], wordForms["ru_noun_pl_acc"]],
            ["Instrumental", wordForms["ru_noun_sg_inst"], wordForms["ru_noun_pl_inst"]],
            ["Prepositional", wordForms["ru_noun_sg_prep"], wordForms["ru_noun_pl_prep"]]
        ]
        
        // We want to find out which string is the longest in each column, this will determine which label to anchor off of
        let longestRowInColumns : [Int] = {
            var longestRows = [Int]()
            for i in 0..<cellTexts.count {
                var currentLongestRowIndex = 0
                for j in 0..<cellTexts[i].count {
                    if let currentRow = cellTexts[i][j], let longestRow = cellTexts[i][currentLongestRowIndex] {
                        if currentRow.count > longestRow.count {
                            currentLongestRowIndex = j
                        }
                    }
                }
                longestRows.append(currentLongestRowIndex)
            }
            return longestRows
        }()
        
        var cells = [[UILabel]]()

        // Create the the row stacks and text labels.
        // The labels will added to the stacks in the order of the cell texts 2d array
        // we are also adding the labels to their own 2d array which will be used to set the anchors
        for row in 0..<cellTexts.count {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 16
            columnStack.addArrangedSubview(rowStack)
            cells.append([])
            
            for column in 0..<cellTexts[row].count {
                if let text = cellTexts[row][column] {
                    // Occasionally a word will have 2 varations for a single form, we will know about by a comma seperating the two forms
                    let varations = text.split(separator: ",")
                    
                    // Most will follow this path, just ignore the varations array and access the text the create the label
                    if varations.count <= 1 {
                        let label = UILabel()
                        label.text = text
                        cells[row].append(label)
                        rowStack.addArrangedSubview(label)
                    } else {
                        // However things will be a bit different if we have multiple varations
                        // Lets create yet another stack to add both varations so they are on different lines
                        let varationStack = UIStackView()
                        varationStack.axis = .vertical
                        var hasAddedToCells = false
                        
                        for varation in varations {
                            let label = UILabel()
                            label.text = String(varation)
                            if !hasAddedToCells { // this just ensures only the first label is added to the cells array
                                cells[row].append(label)
                                hasAddedToCells.toggle()
                            }
                            varationStack.addArrangedSubview(label)
                        }
                        rowStack.addArrangedSubview(varationStack)
                    }
                }
            }
        }
        
        // Here we set the anchors, we will check the row/column to see if it lines up with the index of the longestRowInColumns array. If it doesn't then we know we need to set the anchor
        for row in 0..<cells.count {
            for column in 0..<cells[row].count {
                if longestRowInColumns[row] != column {
                    cells[row][column].widthAnchor.constraint(equalTo: cells[row][longestRowInColumns[row]].widthAnchor).isActive = true
                }
            }
        }
        
        return columnStack
    }
    
    
    /// MARK Temporary Data Holders - Will be removed when database is intergrated
    private func createSampleNoun() -> SampleNoun {
        return SampleNoun(text: "соба́ка",
                          gender: "f",
                          wordType: "noun",
                          ranking: 340,
                          animate: true,
                          translations: ["dog", "the @ sign"],
                          wordForms: [
                            "ru_noun_pl_prep" : "собаках",
                            "ru_noun_pl_inst" : "собаками",
                            "ru_noun_pl_acc" : "собак",
                            "ru_noun_pl_dat" : "собакам",
                            "ru_noun_pl_gen" : "собак",
                            "ru_noun_pl_nom" : "собаки",
                            "ru_noun_sg_prep" : "собаке",
                            "ru_noun_sg_inst" : "собакой,собакою",
                            "ru_noun_sg_acc" : "собаку",
                            "ru_noun_sg_dat" : "собаке",
                            "ru_noun_sg_gen" : "собаки",
                            "ru_noun_sg_nom" : "собака"
                            ],
                          sentences: [
                            ("Соба́ка бежа́ла ему навстречу.", "The dog was running toward him."),
                            ("Соба́ка побежа́ла за лисо́й.", "The dog ran after a fox."),
                            ("Соба́ка подбежа́ла к ней.", "The dog came running to her.")
                          ],
                          relatedWords: ["соба́чий", "соба́читься", "пёс"])
    }
}


private struct SampleNoun {
    let text: String
    let gender: String
    let wordType: String
    let ranking: Int
    let animate: Bool
    let translations: [String]
    let wordForms: [String:String]
    let sentences: [(String, String)]
    let relatedWords: [String]
}
