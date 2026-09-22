import UIKit

class SettingsViewController : UITableViewController {
    private var sections: [SettingsSection] = []
    
    init() {
        super.init(style: .plain)
        build()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SettingPickerWheelTableViewCell.self, forCellReuseIdentifier: "pickerWheel")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if sections.count > indexPath.row {
            let section = sections[indexPath.row]
            switch section.type {
            case .pickerWheel:
                guard let pickerWheelSection = section as? PickerWheelSettingsSection else { return UITableViewCell() }
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "pickerWheel") as? SettingPickerWheelTableViewCell else { return UITableViewCell() }
                cell.configure(title: pickerWheelSection.title, currentSelected: pickerWheelSection.selectedOption)
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = sections[indexPath.row]
        
        switch section.type {
        case .pickerWheel:
            guard let pickerWheelSection = section as? PickerWheelSettingsSection else { return }
            // SettingPickers will have a different enum valve based on the type of picker
            // This changes which view control will be used in the upcoming modal
            let picker: SettingsPicker = {
                switch pickerWheelSection.pickerType {
                case .voice:
                    return VoicePickerViewController(row: indexPath.row)
                case .language:
                    return LanguagePickerViewController(row: indexPath.row)
                }
            }()
            picker.delegate = self // This delegate will be used to call the updateSelectedOption(with text: String, at row: Int) function, which is found in the UpdateSettingSectionDelegate extension of this class
            openSettingPickerModal(picker: picker)
        }
    }
    
    /// Creates the data source to build the UITableView. The data source consists of sections which will show the user the option to change and the currently selected option. Enums are attached to each section which will further handle what will happen when the cell is built and when it is tapped.
    private func build() {
        sections = [
            PickerWheelSettingsSection(
                title: "Default Voice",
                selectedOption: {
                    let defaultVoiceDictionary = UserDefaultsManager.defaultVoice
                    let defaultVoiceName = defaultVoiceDictionary["name"] as? String
                    return defaultVoiceName ?? ""
                }(),
                type: .pickerWheel,
                pickerType: .voice
            ),
            PickerWheelSettingsSection(
                title: "Default Language",
                selectedOption: UserDefaultsManager.defaultLanguage.rawValue,
                type: .pickerWheel,
                pickerType: .language
            )
        ]
    }
    
    /// Slides open a half screen modal displaying a picker wheel, letting the user choose an option
    /// - Parameter picker: A picker wheel view controller that conforms to SettingsPicker
    private func openSettingPickerModal(picker: SettingsPicker) {
        let defaultVoiceChooser = picker
        defaultVoiceChooser.modalPresentationStyle = .pageSheet
        defaultVoiceChooser.sheetPresentationController?.detents = [.medium()]
        present(defaultVoiceChooser, animated: true)
    }
}

extension SettingsViewController: UpdateSettingSectionDelegate {
    /// Updates the data source at the give row
    /// - Parameters:
    ///   - text: The text we will use to change the data source
    ///   - row: The row of the data source, which will be the index value of the sections list
    func updateSelectedOption(with text: String, at row: Int) {
        if sections.count <= row { return } // Given the chance the supplied row is out of the array range, just exit so we don't crash
        
        let section = sections[row]
        
        // Check the enum value for the section type, the value will change depending on the type
        // For now we just have the picker wheel section type, but this may expand in the future as we add more settings
        if section.type == .pickerWheel {
            let pickerSection = section as? PickerWheelSettingsSection
            pickerSection?.selectedOption = text
        }
        
        tableView.reloadData()
    }
}
