import UIKit

protocol TableOfContentsDelegate: AnyObject {
    func chapterTitleClicked(at index: Int)
}

/// A modal which contains the table of contents for a book, the user will be able to choose a chapter and the text will be displayed in the ReaderView
class TableOfContentsController : UITableViewController {
    let chapters: [String]
    
    weak var delegate: TableOfContentsDelegate?
    
    init(chapters: [Chapter]) {
        // Sort the chapters by the index of the chapter, this their logical order, not whatever unordered aray GRDB gave us
        self.chapters = chapters.sorted { $0.index < $1.index }.map { chapter in
            return chapter.name
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
        return chapters.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "chapter") else { return UITableViewCell() }
        var content = cell.defaultContentConfiguration()
        
        // Set the cell text as the chapter title at this index row
        if chapters.count > indexPath.row {
            content.text = chapters[indexPath.row]
        }
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Delegate is sent to the ReaderViewController, which will hold all the information for book including chapters
        delegate?.chapterTitleClicked(at: indexPath.row)
        dismiss(animated: true)
    }
}
