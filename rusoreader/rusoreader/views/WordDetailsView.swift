import UIKit

class WordDetailsView: UIViewController {
    let viewModel: WordDetailsViewModel
    
    init(viewModel: WordDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.addWordToDictionary()
        
        view.backgroundColor = .systemBackground
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false

        view.addSubview(scrollView)
        
        let wordDetailsStack = UIStackView()
        wordDetailsStack.axis = .vertical
        wordDetailsStack.distribution = .fillProportionally
        wordDetailsStack.alignment = .center
        wordDetailsStack.translatesAutoresizingMaskIntoConstraints = false
        wordDetailsStack.spacing = 16
        scrollView.addSubview(wordDetailsStack)

        wordDetailsStack.addArrangedSubview(createWordTitleHeader())
        
        if let translationStack = createTranslationSection() {
            wordDetailsStack.addArrangedSubview(translationStack)
        }
        
        wordDetailsStack.addArrangedSubview(createInformationStack())
        
        switch viewModel.getWordType() {
        case .noun:
            wordDetailsStack.addArrangedSubview(GrammarTable(tableType: .noun, viewModel: viewModel))
        case .verb:
            wordDetailsStack.addArrangedSubview(GrammarTable(tableType: .verb, viewModel: viewModel))
            wordDetailsStack.addArrangedSubview(GrammarTable(tableType: .verbPast, viewModel: viewModel))
        case .adjective:
            wordDetailsStack.addArrangedSubview(GrammarTable(tableType: .adjective, viewModel: viewModel))
        default:
            print("You need to implement all word forms")
        }
        
        if let sentenceStack = createSentenceSection() {
            wordDetailsStack.addArrangedSubview(sentenceStack)
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            wordDetailsStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0),
            wordDetailsStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0),
            wordDetailsStack.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            wordDetailsStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
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
    private func createWordTitleHeader() -> UIStackView {
        let wordStack = UIStackView()
        wordStack.axis = .horizontal
        wordStack.spacing = 32
        wordStack.setContentHuggingPriority(.defaultLow, for: .vertical)
        let wordLabel = UILabel()
        wordLabel.text = viewModel.getWordText()
        wordStack.addArrangedSubview(wordLabel)
        // TODO the add to dictionary will need to handle tap recongization
        let bookImage = UIImage(systemName: "book")
        let addToDicView = UIImageView(image: bookImage)
        wordStack.addArrangedSubview(addToDicView)
        
        return wordStack
    }
    
    private func createInformationStack() -> UIStackView {
        let informationStack = UIStackView()
        informationStack.axis = .vertical
        informationStack.alignment = .center
        
        let informationLabel = UILabel()
        informationLabel.text = viewModel.getWordInformation()
        informationStack.addArrangedSubview(informationLabel)
        
        let rankingLabel = UILabel()
        rankingLabel.text = viewModel.getRankingTitle()
        informationStack.addArrangedSubview(rankingLabel)
        
        return informationStack
    }
    
    /// Creates and configures a UIStackView representing a section of translations.
    /// - Parameters:
    ///     - translations: An array of string translations to display in the section.
    /// - Returns:
    ///     A configured UIStackView representing the translation section, or nil if the input array is empty.
    private func createTranslationSection() -> UIStackView? {
        let translations = viewModel.getTranslations()
        
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
            translationText.text = translation
            translationStack.addArrangedSubview(translationText)
        }
        
        return translationStack
    }

    private func createSentenceSection() -> UIStackView? {
        let sentences = viewModel.getSentences()
        if !sentences.isEmpty {
            let sentenceStack = UIStackView()
            sentenceStack.spacing = 8
            sentenceStack.axis = .vertical
            
            for sentence in sentences {
                if !sentence.translation.isEmpty && !sentence.text.isEmpty {
                    sentenceStack.addArrangedSubview(SentenceView(russianText: viewModel.addStressToSentence(sentence: sentence.text), englishText: sentence.translation))
                }
            }
            
            return sentenceStack
        } else {
            return nil
        }
    }
}
