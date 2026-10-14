import UIKit

protocol TableOfContentsDelegate: AnyObject {
    func chapterTitleClicked(at index: Int)
}

/// A modal which contains the table of contents for a book, the user will be able to choose a chapter and the text will be displayed in the ReaderView
class TableOfContentsController : UITableViewController {
    let indices: [TableOfContentIndex]
    
    weak var delegate: TableOfContentsDelegate?
    
    init(indices: [TableOfContentIndex]) {
        // Sort the chapters by the index of the chapter, this their logical order, not whatever unordered aray GRDB gave us
        self.indices = indices.sorted { $0.index < $1.index }.map { i in
            return i
        }
        
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "chapter")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return indices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "chapter") else { return UITableViewCell() }
        var content = cell.defaultContentConfiguration()
        
        // Set the cell text as the chapter title at this index row
        if indices.count > indexPath.row {
            content.text = indices[indexPath.row].title.capitalized
            if indices[indexPath.row].isHeader {
                content.textProperties.font = UIFont.boldSystemFont(ofSize: 18) 
            }
        }
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Delegate is sent to the ReaderViewController, which will hold all the information for book including chapters
        if !indices[indexPath.row].isHeader {
            dismiss(animated: true) {
                self.delegate?.chapterTitleClicked(at: indexPath.row)
            }
        }
    }
}
