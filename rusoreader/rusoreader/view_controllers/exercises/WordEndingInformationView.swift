import UIKit

/// Used in exercises which involve the user choosing the correct ending. This will show the word in it's base on top of which form the user needs to correctly put the word into
final class WordEndingInformationView : UIStackView {
    init(accentedWord: String, wordFormText: String) {
        super.init(frame: .zero)

        axis = .vertical
        alignment = .center
        translatesAutoresizingMaskIntoConstraints = false
        
        let wordLabel = UILabel()
        wordLabel.font = .preferredFont(forTextStyle: .headline)
        wordLabel.text = accentedWord
        addArrangedSubview(wordLabel)
        
        let wordFormLabel = UILabel()
        wordFormLabel.font = .preferredFont(forTextStyle: .subheadline)
        wordFormLabel.text = wordFormText
        addArrangedSubview(wordFormLabel)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}