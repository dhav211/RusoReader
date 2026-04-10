import UIKit

class ReaderView: UIViewController, UITextViewDelegate {
    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.isEditable = false
        textView.delegate = self
    }
    
    func textView(_ textView: UITextView, editMenuForTextIn range: NSRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
        let selectedRange = Range(range, in: self.textView.text)
        
        let selectedText = self.textView.text[selectedRange!].split(separator: " ")
        
        let lookupAction = UIAction(title: "Look Up") { action in
            print("Let's look up this word")
        }
        let translateSentenceAction = UIAction(title: "Translate Sentence") { action in
            print("Let's translate this sentence")
        }
        
        if selectedText.count == 1 {
            return UIMenu(title: "", options: .displayInline, children: [lookupAction])
        } else {
            return UIMenu(title: "", options: .displayInline, children: [translateSentenceAction])
        }
    }
}
