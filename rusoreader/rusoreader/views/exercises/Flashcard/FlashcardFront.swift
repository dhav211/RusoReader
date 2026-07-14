import UIKit
class FlashcardFront : UIView {
    var onFlipCard: () -> Void
    var onRunTTS: () -> Void
    
    init(wordText: String) {
        self.onFlipCard = {}
        self.onRunTTS = {}
        
        super.init(frame: .zero)
        
        setup(wordText: wordText)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(wordText: String) {
        // The front of the card will show the russian word and then two icons for flipping the card and running the TTS engine to see how word is pronounced
        translatesAutoresizingMaskIntoConstraints = false
        layer.borderColor = UIColor.systemGray.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 8
        
        // The basic vertical stack to hold the word on one row then the icons on the next
        let rowStack = UIStackView()
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        rowStack.axis = .vertical
        rowStack.alignment = .center
        rowStack.spacing = 16
        addSubview(rowStack)
        
        // The accented version of the russian word
        let wordLabel = UILabel()
        wordLabel.text = wordText
        wordLabel.font = .preferredFont(forTextStyle: .largeTitle)
        rowStack.addArrangedSubview(wordLabel)
        
        // We will place both icons in this horizontal stack view which will be underneath the russian word
        let iconStack = UIStackView()
        iconStack.axis = .horizontal
        rowStack.addArrangedSubview(iconStack)
        
        let configuration = UIImage.SymbolConfiguration(pointSize: 24) // The size of the icon buttons
                                                        
        // The user must click this icon for the card to flip over, once flipped the card cannot be flipped again
        let flipIcon = UIImage(systemName: "arrow.2.squarepath", withConfiguration: configuration)
        let flipButton = UIButton()
        flipButton.setImage(flipIcon, for: .normal)
        flipButton.addTarget(self, action: #selector(flipCardButtonPressed), for: .touchUpInside)
        iconStack.addArrangedSubview(flipButton)
        
        // The default ios TTS image will play the pronounication of the word
        let playSoundIcon = UIImage(systemName: "speaker.wave.2.fill", withConfiguration: configuration)
        let playSound = UIButton()
        playSound.setImage(playSoundIcon, for: .normal)
        playSound.addTarget(self, action: #selector(speakerButtonPressed), for: .touchUpInside)
        iconStack.addArrangedSubview(playSound)
        
        NSLayoutConstraint.activate([
            rowStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            rowStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            rowStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            rowStack.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    @objc private func flipCardButtonPressed() {
        onFlipCard()
    }
    
    @objc private func speakerButtonPressed() {
        onRunTTS()
    }
}
