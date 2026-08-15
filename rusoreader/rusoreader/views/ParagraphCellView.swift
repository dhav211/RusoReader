import UIKit

class ParagraphCellView : UITableViewCell {
    private let paragraphView: ParagraphView
    static let reuseID = "paragraph"
    private var index = 0
    
    var onTextClicked: ((ParagraphView, CGPoint, Int) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        paragraphView = ParagraphView()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(paragraphView)
        NSLayoutConstraint.activate([
            paragraphView.topAnchor.constraint(equalTo: contentView.topAnchor),
            paragraphView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            paragraphView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            paragraphView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setText(with text: NSMutableAttributedString) {
        paragraphView.attributedText = text
    }
    
    func getText() -> String {
        return paragraphView.text
    }
    
    func setIndex(to value: Int) {
        index = value
    }
    
    func getIndex() -> Int {
        return index
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        onTextClicked?(paragraphView, gesture.location(in: self), index)
    }
}
