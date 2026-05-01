import UIKit

class WordDetailsView: UIViewController {
    let words: [Word]
    
    init(words: [Word]) {
        self.words = words
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        guard let word = words.first else { return }
        
        //let scrollView = UIScrollView()
        let wordDetailsStack = UIStackView()
        wordDetailsStack.axis = .vertical
        wordDetailsStack.distribution = .fillProportionally
        wordDetailsStack.alignment = .center
        wordDetailsStack.translatesAutoresizingMaskIntoConstraints = false
        wordDetailsStack.spacing = 16
        view.addSubview(wordDetailsStack)

        wordDetailsStack.addArrangedSubview(createWordTitleHeader(for: word.bare))
        
        if let translationStack = createTranslationSection(with: word.translations) {
            wordDetailsStack.addArrangedSubview(translationStack)
        }
        
        wordDetailsStack.addArrangedSubview(createWordInformation(for: word))
        
        switch word.type {
        case .noun:
            wordDetailsStack.addArrangedSubview(createGrammarTable(from: word, as: .noun))
        case .verb:
            wordDetailsStack.addArrangedSubview(createGrammarTable(from: word, as: .verb))
            wordDetailsStack.addArrangedSubview(createGrammarTable(from: word, as: .verbPast))
        case .adjective:
            wordDetailsStack.addArrangedSubview(createGrammarTable(from: word, as: .adjective))
        default:
            print("You need to implement all word forms")
        }
        
        NSLayoutConstraint.activate([
            wordDetailsStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            wordDetailsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            wordDetailsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0)
        ])
    }
    
    /// MARK Element Creation Methods
    
    /// Creates and configures a UIStackView representing a title header for a word.
    /// 
    /// This function uses a string word to create a stack view with a label displaying the word's name and an image indicating that it can be added to a dictionary.
    /// The stack view is horizontally arranged and has a vertical spacing of 32 points.
    /// - Parameters:
    ///     - word: A string representing the word's name.
    /// - Returns: A configured UIStackView representing the title header for the word.
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
    
    /// Creates and configures a UIStackView representing a section of translations.

    /// This function uses an array of string translations to create a stack view with a header label and multiple translation text labels.
    /// If the input array is empty, the function returns nil.

    /// - Parameters:
    ///     - translations: An array of string translations to display in the section.

    /// - Returns:
    ///     A configured UIStackView representing the translation section, or nil if the input array is empty.
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
            translationText.text = "- \(translation)"
            translationStack.addArrangedSubview(translationText)
        }
        
        return translationStack
    }
    
    /// Creates and configures a UILabel displaying word information, such as part of speech, gender, animate, etc.

    ///  This function uses data from a Word object to create a label that displays the word's type, attributes (e.g. noun gender, verb aspect), and ranking.
    ///  The label text is generated based on the word's properties.

    /// - Parameters:
    ///     - word: A Word object containing information about the word.

    /// - Returns:
    ///     A configured UILabel displaying the word's information.
    private func createWordInformation(for word: Word) -> UILabel {
        let informationLabel = UILabel()
        var information = ""
            
        // The word information will change depending on if it's noun, verb, adjective
        switch word.type {
        case .noun:
            information.append("Noun")
            if let noun = word.noun {
                if noun.gender == Noun.Gender.female {
                    information.append(", female")
                } else if noun.gender == Noun.Gender.male {
                    information.append(", male")
                } else if noun.gender == Noun.Gender.neuter {
                    information.append(", neuter")
                } else {
                    information.append(", male & female")
                }
                
                if noun.animate {
                    information.append(", animate")
                } else {
                    information.append(", inanimate")
                }
            }
        case .verb:
            information.append("Verb")
            if let verb = word.verb {
                information.append(", \(verb.aspect.rawValue)")
            }
        case .adjective:
            information.append("Adjective")
        case .adverb:
            information.append("Adverb")
        case.other:
            information.append("Other")
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
    
    /// Creates and configures a UIStackView representing a grammar table.
    ///
    /// This function uses data from a Word object and a GrammarFormTableData instance to create a table with rows and columns, where each cell contains text labels.
    /// The layout of the cells is determined by the longest row in each column.
    /// - Parameters:
    ///   - word: A Word object containing information about the grammar forms of the word.
    ///   - grammarTableType: An enum value indicating the type of grammar form table to create (e.g. noun, verb, adjective).
    /// - Returns: A configured UIStackView representing the grammar table.
    private func createGrammarTable(from word: Word, as grammarTableType: GrammarFormTableData.TableType) -> UIStackView {
        let columnStack = UIStackView()
        columnStack.axis = .vertical
        columnStack.distribution = .fill
        columnStack.spacing = 4

        let grammarFormTableData = GrammarFormTableData(wordForms: word.forms, grammarTableType: grammarTableType)
        
        // We want to find out which string is the longest in each column, this will determine which label to anchor off of
        let longestRowInColumns : [Int] = {
            var longestRows = [Int]()
            for i in 0..<grammarFormTableData.forms.count {
                var currentLongestRowIndex = 0
                for j in 0..<grammarFormTableData.forms[i].count {
                    if grammarFormTableData.forms[i][j].text.count > grammarFormTableData.forms[i][currentLongestRowIndex].text.count {
                        currentLongestRowIndex = j
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
        for row in 0..<grammarFormTableData.forms.count {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 16
            columnStack.addArrangedSubview(rowStack)
            cells.append([])
            
            for column in 0..<grammarFormTableData.forms[row].count {
                // Occasionally a word will have 2 varations for a single form, we will know about by a comma seperating the two forms
                let varations = grammarFormTableData.forms[row][column].text.split(separator: ",")
                
                // Most will follow this path, just ignore the varations array and access the text the create the label
                if varations.count <= 1 {
                    let label = UILabel()
                    label.text = getLabelTextFromCell(
                        wordText: grammarFormTableData.forms[row][column].text,
                        isRussianWord: grammarFormTableData.forms[row][column].isRussianWord,
                        isAdjective: word.type == .adjective)
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
                        label.text = getLabelTextFromCell(
                            wordText: String(varation),
                            isRussianWord: true,
                            isAdjective: word.type == .adjective)
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
    
    /// Generates a label text from a given cell's word text based on its language and type.
    ///
    /// This function takes into account whether the word is a Russian word or a column/row header and whether it's an adjective, which would if it is and also long enough then we should only display the ending
    /// - Parameters:
    ///    - wordText: The original word text from the cell.
    ///    - isRussianWord: A boolean indicating whether the word is in Russian.
    ///    - isAdjective: A boolean indicating whether the word is an adjective.
    /// - Returns: A string representing the generated label text for the cell.
    private func getLabelTextFromCell(wordText: String, isRussianWord: Bool, isAdjective: Bool) -> String {
        if isRussianWord {
            if !isAdjective {
                return wordText
            } else {
                if wordText.count > 5 { // If an adjective is longer than 5 letters then lets just display the endings
                    return getAdjectiveEnding(for: wordText)
                } else {
                    return wordText
                }
            }
        } else {
            return wordText
        }
    }
    
    /// Extracts and returns the ending part of an adjective.
    ///
    /// This function uses the base form of the adjective (found using `findAdjectiveBase`) to split it into two parts: the base and the ending.
    /// It then returns only the ending part, excluding the base.
    /// - Parameters:
    ///   - adjective: The adjective from which to extract the ending part, as a `String`.
    /// - Returns: A string representing the extracted ending part of the adjective.
    private func getAdjectiveEnding(for adjective: String) -> String {
        let adjectiveBase = WordUtils.findAdjectiveBase(for: adjective)
        let baseRange = adjective.range(of: adjectiveBase)
        return "-\(adjective[baseRange!.upperBound..<adjective.endIndex])"
    }
}
