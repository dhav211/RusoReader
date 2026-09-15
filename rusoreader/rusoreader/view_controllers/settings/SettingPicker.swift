import UIKit

protocol SettingPicker: UIPickerViewDelegate, UIPickerViewDataSource {
    var selectionButton: UIButton { get }
    var informationLabel: UILabel { get }
    func activateSelection()
}
