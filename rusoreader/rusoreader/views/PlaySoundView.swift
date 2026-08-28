import UIKit

final class PlaySoundView: UIImageView {
    private let speechSynth: SpeechSynth
    private let textToSpeak: String

    init(textToSpeak: String) {
        self.speechSynth = SpeechSynth()
        self.textToSpeak = textToSpeak
        super.init(frame: .zero)
        image = UIImage(systemName: "speaker.wave.2.fill")
        isUserInteractionEnabled = true
        translatesAutoresizingMaskIntoConstraints = false
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