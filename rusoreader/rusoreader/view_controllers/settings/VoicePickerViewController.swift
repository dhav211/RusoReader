import UIKit
import AVFAudio

final class VoicePickerViewController : UIViewController, SettingsPicker {
    let row: Int
    let viewPicker: UIPickerView
    private let voices: [AVSpeechSynthesisVoice]
    private var selectedVoice: AVSpeechSynthesisVoice?
    let selectionButton = UIButton()
    let informationLabel = UILabel()
    
    weak var delegate: UpdateSettingSectionDelegate?
    
    init(row: Int) {
        self.row = row
        self.viewPicker = UIPickerView()
        self.voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language == "ru-RU" }

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        viewPicker.translatesAutoresizingMaskIntoConstraints = false
        viewPicker.delegate = self
        view.addSubview(viewPicker)
        
        // Check the UserDefaults to see if there has already been a default voice to preselect, if not just preselect the first voice
        let defaultVoiceDictionary = UserDefaultsManager.defaultVoice
        let defaultVoiceIdentifier = defaultVoiceDictionary["identifier"] as? String
        let defaultVoice = voices.first(where: { $0.identifier == defaultVoiceIdentifier })
        if let defaultVoice, let index = voices.firstIndex(of: defaultVoice) {
            viewPicker.selectRow(index, inComponent: 0, animated: false)
            selectedVoice = defaultVoice
        } else {
            viewPicker.selectRow(0, inComponent: 0, animated: false)
            if let firstVoice = voices.first {
                selectedVoice = firstVoice
            }
        }
        
        // The information stack will hold the label and button horizontally of each other
        let informationStack = SettingsPickerInformationStack(information: "Choose a default voice") { [weak self] in
            self?.activateSelection()
        }
        view.addSubview(informationStack)
        
        
        NSLayoutConstraint.activate([
            informationStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            informationStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            informationStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            viewPicker.topAnchor.constraint(equalTo: informationStack.bottomAnchor, constant: 16),
            viewPicker.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            viewPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func activateSelection() {
        guard let selectedVoice else { return }
        
        let defaultVoice = [
            "identifier": selectedVoice.identifier,
            "name": selectedVoice.name
        ]
        
        UserDefaultsManager.defaultVoice = defaultVoice
        self.delegate?.updateSelectedOption(with: selectedVoice.name, at: self.row)
        
        dismiss(animated: true)
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
        selectedVoice = voices[row]
    }
}
