import UIKit

protocol ParagraphCellViewDelegate: AnyObject {
    func didClickText(in paragraphView: ParagraphView, at location: CGPoint)
}

class ParagraphCellView : UITableViewCell {
    private let paragraphView: ParagraphView
    static let reuseID = "paragraph"
    weak var delegate: ParagraphCellViewDelegate?
    
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
    
    func setText(with text: String) {
        paragraphView.text = text
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        delegate?.didClickText(in: paragraphView, at: gesture.location(in: self))
    }
}
