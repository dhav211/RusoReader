import UIKit

class WordDetailsView: UIViewController {
    let words: [Word]
    let viewModel: WordDetailsViewModel
    
    init(words: [Word], viewModel: WordDetailsViewModel) {
        self.words = words
        self.viewModel = viewModel
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
        
        wordDetailsStack.addArrangedSubview(createInformationStack(for: word))
        
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
    
    private func createInformationStack(for word: Word) -> UIStackView {
        let informationStack = UIStackView()
        informationStack.axis = .vertical
        informationStack.alignment = .center
        
        let informationLabel = UILabel()
        informationLabel.text = viewModel.getWordInformation(word: word)
        informationStack.addArrangedSubview(informationLabel)
        
        let rankingLabel = UILabel()
        rankingLabel.text = viewModel.getRankingTitle(ranking: word.ranking)
        informationStack.addArrangedSubview(rankingLabel)
        
        return informationStack
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
        let longestRowInColumns = viewModel.getLongestRows(grammarFormTableData: grammarFormTableData)
        
        // We are holding all the labels so we can compare them the the longestRowInColumns array to see which label is the biggest, then we use that as a width anchor for getting centering
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
                let varationStack = UIStackView()
                varationStack.axis = .vertical
                rowStack.addArrangedSubview(varationStack)
                
                // Create the labels based on the possible variations of the word form, most words will consist of a single varation but there are predictable exceptions
                let varationsLabels = viewModel.getWordFormVariations(
                    for: grammarFormTableData.forms[row][column],
                    isAdjective: word.type == .adjective
                ).map { varation in
                    let label = UILabel()
                    label.text = varation
                    label.adjustsFontSizeToFitWidth = true
                    return label
                }
                
                if varationsLabels.isEmpty { // there will be no variations for the top left corner of the grid, but an empty label is still required for anchoring
                    let label = UILabel()
                    cells[row].append(label)
                    varationStack.addArrangedSubview(label)
                } else if let firstVariation = varationsLabels.first { // the first variation is always added as the to cells array for anchoring
                    cells[row].append(firstVariation)
                }
                
                for label in varationsLabels {
                    varationStack.addArrangedSubview(label)
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
