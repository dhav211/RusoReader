import UIKit
class SentenceView : UIStackView {
    init(russianText: String, englishText: String) {
        super.init(frame: .zero)
        
        axis = .vertical
        
        let russian = UILabel()
        russian.text = russianText
        russian.numberOfLines = 0
        addArrangedSubview(russian)
        
        let english = UILabel()
        english.text = englishText
        english.numberOfLines = 0
        english.textColor = .systemGray
        addArrangedSubview(english)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
