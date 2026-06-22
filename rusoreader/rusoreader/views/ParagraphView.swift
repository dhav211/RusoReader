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
    
    func removeHighlight(selectionRange: SelectionRange) {
        textStorage.addAttribute(.foregroundColor, value: UIColor.label, range: selectionRange.wordRange)
        textStorage.removeAttribute(.underlineStyle, range: selectionRange.sentenceRange)
    }
    
    func highlightSelection(selectionRange: SelectionRange) {
        //textStorage.addAttribute(.foregroundColor, value: UIColor.red, range: selectionRange.wordRange)
        textStorage.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: selectionRange.wordRange)
        textStorage.addAttribute(.underlineColor, value: UIColor.blue, range: selectionRange.wordRange)
    }
}
