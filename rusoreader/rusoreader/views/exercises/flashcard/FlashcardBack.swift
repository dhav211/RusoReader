import UIKit

/// A custom view that displays the back side of a flashcard, showing translations of a word and an example sentence.
///
/// `FlashcardBack` presents multiple translations in a vertical stack and displays an attributed sentence
/// with bolded and underlined text to highlight the target word in context.
class FlashcardBack : UIView {
    init(translations: [String], sentence: AttributedSentence) {
        super.init(frame: .zero)
        
        setup(translations: translations, sentence: sentence)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// This hold the sentence's text and the bolded range which will tell the attributed string what needs to be bolded and underlined
    struct AttributedSentence {
        let text: String
        let boldedRange: NSRange?
    }
    
    private func setup(translations: [String], sentence: AttributedSentence) {
        translatesAutoresizingMaskIntoConstraints = false
        layer.borderColor = UIColor.systemGray.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 8
        
        let rowStack = UIStackView()
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        rowStack.axis = .vertical
        rowStack.alignment = .center
        rowStack.spacing = 16
        addSubview(rowStack)
        
        // Since we can have multiple translations of a word we will place each in a stack
        let translationStack = UIStackView()
        translationStack.axis = .vertical
        rowStack.addArrangedSubview(translationStack)
        
        for translation in translations {
            let translationLabel = UILabel()
            translationLabel.text = translation
            translationLabel.numberOfLines = 0
            translationStack.addArrangedSubview(translationLabel)
        }
        
        // Display a random sentence associated with this word
        // TODO in the future we will save the sentence where the words originated, and we will show it here
        
        // Create an attributed string with the target word bolded and underlined
        let boldedSentence: NSMutableAttributedString = {
            let attributedString = NSMutableAttributedString(string: sentence.text)
            
            if let boldedRange = sentence.boldedRange {
                let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 17), .underlineStyle: NSUnderlineStyle.single.rawValue]
                attributedString.addAttributes(attributes, range: boldedRange)
            }
            
            return attributedString
        }()
        
        let sentenceLabel = UILabel()
        sentenceLabel.attributedText = boldedSentence
        sentenceLabel.numberOfLines = 0
        rowStack.addArrangedSubview(sentenceLabel)
        
        NSLayoutConstraint.activate([
            rowStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            rowStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            rowStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            rowStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
