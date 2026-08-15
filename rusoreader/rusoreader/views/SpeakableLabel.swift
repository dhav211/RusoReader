import UIKit

final class SpeakableLabel: UILabel {
    private let speechSynth: SpeechSynth
    private let textToSpeak: String
    
    init(textToSpeak: String, speechSynth: SpeechSynth,textToDisplay: String = "", font: UIFont = UIFont.preferredFont(forTextStyle: .body)) {
        self.speechSynth = speechSynth
        self.textToSpeak = textToSpeak
        
        super.init(frame: .zero)

        self.font = font
        self.text = textToDisplay.isEmpty ? textToSpeak : textToDisplay
        self.isUserInteractionEnabled = true // A gotcha with UILabels, without this tap will be ignored
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap(_:))))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didTap(_ sender: UITapGestureRecognizer) {        
        do {
            try speechSynth.speak(content: textToSpeak)
        } catch {
            // This needs to open a ui alert letting the user know there was an error
            print("!!!")
        }
    }
}