import UIKit
class ParagraphView: UITextView {
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
        isScrollEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateParagraphText(updatedParagraph: NSMutableAttributedString) {
        textStorage.setAttributedString(updatedParagraph)
    }
}
