import UIKit

final class WordDetailsStackView: UIStackView {
    private let viewModel: WordDetailsViewModel
    private let speechSynth: SpeechSynth
    
    init(viewModel: WordDetailsViewModel, speechSynth: SpeechSynth) {
        self.viewModel = viewModel
        self.speechSynth = speechSynth
        
        super.init(frame: .zero)
        
        setup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        axis = .vertical
        distribution = .fillProportionally
        alignment = .center
        translatesAutoresizingMaskIntoConstraints = false
        spacing = 16
        
        addArrangedSubview(
            SpeakableLabel(textToSpeak: viewModel.getWordText(), speechSynth: speechSynth)
        )
        
        if let translationStack = createTranslationSection() {
            addArrangedSubview(translationStack)
        }
        
        addArrangedSubview(createInformationStack())
        
        switch viewModel.getWordType() {
        case .noun:
            addArrangedSubview(GrammarTable(tableType: .noun, viewModel: viewModel, speechSynth: speechSynth))
        case .verb:
            if let verbAspect = viewModel.getVerbAspect() {
                addArrangedSubview(GrammarTable(
                    tableType: verbAspect == .imperfective ? .verbPresent : .verbFuture,
                    viewModel: viewModel,
                    speechSynth: speechSynth
                ))
                addArrangedSubview(GrammarTable(tableType: .verbPast, viewModel: viewModel, speechSynth: speechSynth))
            }
        case .adjective:
            addArrangedSubview(GrammarTable(tableType: .adjective, viewModel: viewModel, speechSynth: speechSynth))
        default:
            print("You need to implement all word forms")
        }
        
        if let sentenceStack = createSentenceSection() {
            addArrangedSubview(sentenceStack)
        }
    }
    
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
        let wordLabel = SpeakableLabel(textToSpeak: viewModel.getWordText(), speechSynth: SpeechSynth())
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
