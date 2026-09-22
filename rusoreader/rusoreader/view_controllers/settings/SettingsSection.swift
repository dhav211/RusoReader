/// A SettingsSection is the data source for the SettingsViewController UITable
protocol SettingsSection {
    var title: String { get }
    var type: SettingsSectionType { get }
}

protocol SettingsPickerSection: SettingsSection {
    var pickerType: SettingsPickerType { get }
}
