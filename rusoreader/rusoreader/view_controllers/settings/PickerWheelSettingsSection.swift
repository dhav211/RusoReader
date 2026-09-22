final class PickerWheelSettingsSection: SettingsPickerSection {
    let title: String
    var selectedOption: String
    let type: SettingsSectionType
    let pickerType: SettingsPickerType
    
    init(title: String, selectedOption: String, type: SettingsSectionType, pickerType: SettingsPickerType) {
        self.title = title
        self.selectedOption = selectedOption
        self.type = type
        self.pickerType = pickerType
    }
}
