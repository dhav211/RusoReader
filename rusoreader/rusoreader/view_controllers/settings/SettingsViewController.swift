import UIKit

final class SettingsViewController : UITableViewController {
    enum SettingsSelection {
        case toggle(title: String, isOn: Bool, action: (Bool) -> Void)
        case basic(title: String, action: (() -> Void)?)
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "basic")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "basic") else { return UITableViewCell() }
        var content = cell.defaultContentConfiguration()
        
        // Set the cell text as the chapter title at this index row
        if sections.count > indexPath.row {
            switch sections[indexPath.row] {
            case .basic(let title, _):
                content.text = title
                content.secondaryText = "testy"
            case .toggle(let title, let isOn, _):
                content.text = title
            }
        }
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = sections[indexPath.row]
        
        switch row {
        case .basic(_, let action):
            action?()
        case .toggle:
            break
        }
    }

    private func build() {
        sections = [
            .basic(title: "Default Voice", action: openDefaultVoiceSelectionMenu)
        ]
    }
    
    private func openDefaultVoiceSelectionMenu() {
        let defaultVoiceChooser = ChooseDefaultVoiceViewController()
        defaultVoiceChooser.modalPresentationStyle = .pageSheet
        defaultVoiceChooser.sheetPresentationController?.detents = [.medium()]
        present(defaultVoiceChooser, animated: true)
    }
}
