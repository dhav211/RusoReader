import UIKit

enum ParagraphMarginSize {
    case phonePortrait
    case phoneLandscape
    case tablet
}

class ParagraphCellView : UITableViewCell {
    private let paragraphView: ParagraphView
    static let reuseID = "paragraph"
    private var index = 0
    private var leadingConstraint: NSLayoutConstraint? = nil
    private var trailingConstraint: NSLayoutConstraint? = nil
    
    var onTextClicked: ((ParagraphView, CGPoint, Int) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        paragraphView = ParagraphView()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(paragraphView)
        
        trailingConstraint = paragraphView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        leadingConstraint = paragraphView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        
        NSLayoutConstraint.activate([
            paragraphView.topAnchor.constraint(equalTo: contentView.topAnchor),
            paragraphView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            trailingConstraint!,
            leadingConstraint!
        ])
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setMargins(to size: ParagraphMarginSize) {
        typealias MarginSize = (CGFloat, CGFloat)
        let marginSize: MarginSize = {
            switch size {
            case .phonePortrait:
                return MarginSize(16,-16)
            case .phoneLandscape:
                return MarginSize(16, 8)
            case .tablet:
                return MarginSize(32, -32)
            }
        }()
        
        leadingConstraint?.constant = marginSize.0
        trailingConstraint?.constant = marginSize.1
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
