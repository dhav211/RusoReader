import UIKit

final class SettingsViewController : UITableViewController {
    enum SettingsSelection {
        case toggle(title: String, isOn: Bool, action: (Bool) -> Void)
        case pickerWheel(title: String, selectedOption: String, onClicked: (() -> Void)?)
    }
    
    private var sections: [SettingsSelection] = []
    
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
            switch sections[indexPath.row] {
            case .pickerWheel(let title, let selectedOption, _):
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "pickerWheel") as? SettingPickerWheelTableViewCell else { return UITableViewCell() }
                cell.configure(title: title, currentSelected: selectedOption)
                
                return cell
            case .toggle(let title, let isOn, _):
                //content.text = title
                return UITableViewCell()
            }
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = sections[indexPath.row]
        
        switch row {
        case .pickerWheel(_, _, let action):
            action?()
        case .toggle:
            break
        }
    }

    private func build() {
        sections = [
            .pickerWheel(
                title: "Default Voice",
                selectedOption: {
                    let defaultVoiceDictionary = UserDefaults.standard.dictionary(forKey: "defaultVoice")
                    let defaultVoiceName = defaultVoiceDictionary?["name"] as? String
                    return defaultVoiceName ?? ""
                }(),
                onClicked: openDefaultVoiceSelectionMenu
            )
        ]
    }
    
    private func openDefaultVoiceSelectionMenu() {
        let defaultVoiceChooser = ChooseDefaultVoiceViewController()
        defaultVoiceChooser.modalPresentationStyle = .pageSheet
        defaultVoiceChooser.sheetPresentationController?.detents = [.medium()]
        present(defaultVoiceChooser, animated: true)
    }
}
