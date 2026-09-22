import UIKit

final class LanguagePickerViewController: UIViewController, SettingsPicker {
    let row: Int
    let viewPicker = UIPickerView()
    let selectionButton = UIButton()
    let informationLabel = UILabel()
    private let languages: [Language] = [.English, .Russian]
    private var selectedLangauge: Language?
    
    weak var delegate: UpdateSettingSectionDelegate?
    
    init(row: Int) {
        self.row = row
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        viewPicker.translatesAutoresizingMaskIntoConstraints = false
        viewPicker.delegate = self
        view.addSubview(viewPicker)
        
        // Set the view pickers default choice based on the default language set in the user defaults
        let defaultLanguage = UserDefaultsManager.defaultLanguage
        if let index = languages.firstIndex(of: defaultLanguage) {
            viewPicker.selectRow(index, inComponent: 0, animated: false)
        } else {
            viewPicker.selectRow(0, inComponent: 0, animated: false)
            if let firstLangauge = languages.first {
                selectedLangauge = firstLangauge
            }
        }
        
        // The information stack will hold the label and button horizontally of each other
        let informationStack = SettingsPickerInformationStack(information: "Choose a default language") { [weak self] in
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
        // set the default language in the user preferences
        guard let selectedLangauge else { return }
        UserDefaultsManager.defaultLanguage = selectedLangauge
        self.delegate?.updateSelectedOption(with: selectedLangauge.rawValue, at: self.row)
        dismiss(animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return languages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedLangauge = languages[row]
    }
}
