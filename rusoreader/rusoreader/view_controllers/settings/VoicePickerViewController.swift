import UIKit
import AVFAudio

final class ChooseDefaultVoiceViewController : UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    private let voicePickerView: UIPickerView
    private let voices: [AVSpeechSynthesisVoice]
    private var selectedVoiceIdentifer: String?
    private var selectionButton: UIButton
    
    init() {
        self.voicePickerView = UIPickerView()
        self.voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language == "ru-RU" }
        self.selectionButton = UIButton()

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        voicePickerView.translatesAutoresizingMaskIntoConstraints = false
        voicePickerView.delegate = self
        view.addSubview(voicePickerView)
        
        // Check the UserDefaults to see if there has already been a default voice to preselect, if not just preselect the first voice
        let defaultVoiceIdentifer = String(UserDefaults.standard.string(forKey: "default-voice") ?? "")
        let defaultVoice = voices.first(where: { $0.identifier == defaultVoiceIdentifer })
        if let defaultVoice, let index = voices.firstIndex(of: defaultVoice) {
            voicePickerView.selectRow(index, inComponent: 0, animated: false)
            selectedVoiceIdentifer = defaultVoiceIdentifer
        } else {
            voicePickerView.selectRow(0, inComponent: 0, animated: false)
            if let firstVoice = voices.first {
                selectedVoiceIdentifer = firstVoice.identifier
            }
        }
        
        // The information stack will hold the label and button horizontally of each other
        let informationStack = UIStackView()
        view.addSubview(informationStack)
        informationStack.translatesAutoresizingMaskIntoConstraints = false
        informationStack.axis = .horizontal
        informationStack.distribution = .equalSpacing
        
        let informationLabel = UILabel()
        informationLabel.text = "Choose a default voice"
        
        selectionButton.setTitle("Select", for: .normal)
        selectionButton.setTitleColor(.systemBlue, for: .normal)
        selectionButton.addTarget(self, action: #selector(onSelectTapped), for: .touchUpInside)
        
        informationStack.addArrangedSubview(informationLabel)
        informationStack.addArrangedSubview(selectionButton)
        
        NSLayoutConstraint.activate([
            informationStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            informationStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            informationStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            voicePickerView.topAnchor.constraint(equalTo: informationStack.bottomAnchor, constant: 16),
            voicePickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            voicePickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            voicePickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    /// When the selection button is pressed set the voice's identifer in the user defaults and close this modal
    @objc private func onSelectTapped() {
        guard let selectedVoiceIdentifer else { return }
        dismiss(animated: true) {
            UserDefaults.standard.set(selectedVoiceIdentifer, forKey: "default-voice")
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // There will only ever be one group of langages, and that's russian of course
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return voices.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return voices[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // When the user hovers over the voice we will set the selectedVoiceIdentifer, this is an unique code that won't have any duplicates
        selectedVoiceIdentifer = voices[row].identifier
    }
    
    
}
