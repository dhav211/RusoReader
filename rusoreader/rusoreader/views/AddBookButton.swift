import UIKit

protocol AddBookButtonDelegate : AnyObject {
    func didClickAddBookButton(addBookButton: AddBookButton)
}

class AddBookButton : UIButton {
    weak var delegate : AddBookButtonDelegate?
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setTitle("Add Book", for: .normal)
        setTitleColor(.label, for: .normal)
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleTap() {
        delegate?.didClickAddBookButton(addBookButton: self)
    }
}
