import UIKit

protocol ReaderViewDelegate: AnyObject {
    func didClickText(at location: CGPoint)
}

class ReaderView: UITextView {
    weak var readerDelegate: ReaderViewDelegate?
    
    init() {
        let storage = NSTextStorage()
        let manager = NSLayoutManager()
        let container = NSTextContainer()
        
        storage.addLayoutManager(manager)
        manager.addTextContainer(container)
        
        super.init(frame: .zero, textContainer: container)
        
        showsVerticalScrollIndicator = false
        translatesAutoresizingMaskIntoConstraints = false
        isEditable = false
        isSelectable = false
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadText(text: String) {
        contentOffset = .zero
        attributedText = NSMutableAttributedString(string: text,
                                                   attributes: [
                                                        .foregroundColor: UIColor.label,
                                                        .font: UIFont.systemFont(ofSize: 24)
                                                   ]
        )
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        readerDelegate?.didClickText(at: gesture.location(in: self))
    }
}
