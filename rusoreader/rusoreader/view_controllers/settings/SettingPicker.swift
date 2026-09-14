import UIKit

protocol SettingPicker: UIPickerViewDelegate, UIPickerViewDataSource {
    var selectionButton: UIButton { get }
    func activateSelection()
}
