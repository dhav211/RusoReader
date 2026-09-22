import UIKit

protocol SettingsPicker: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var row: Int { get }
    var viewPicker: UIPickerView { get }
    var selectionButton: UIButton { get }
    var informationLabel: UILabel { get }
    func activateSelection()
    var delegate: UpdateSettingSectionDelegate? { get set }
}
