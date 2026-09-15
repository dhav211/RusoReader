import UIKit

final class LanguagePickerViewController: UIViewController, SettingPicker {
    let selectionButton = UIButton()
    let informationLabel = UILabel()
    let languages = ["English", "Russian"]
    
    
    func activateSelection() {
        // set the default language in the user preferences
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0
        //return language.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ""
        //return voices[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //selectedVoiceIdentifer = voices[row].identifier
    }
}
