import UIKit

class HomePageController: UIViewController {
    let dbManager: DatabaseManager
    let bookRepo: BookRepository
    lazy var bookSelector: BookSelector = BookSelector(bookRepo: BookRepository(databaseManager: dbManager, fileStore: FileStore(directory: .documentsDirectory)))
    
    init(dbManager: DatabaseManager) {
        self.dbManager = dbManager
        self.bookRepo = BookRepository(databaseManager: dbManager)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let libraryLabel = UILabel()
        libraryLabel.text = "Your Library"
        libraryLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        libraryLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(libraryLabel)
        
        view.addSubview(bookSelector)
        bookSelector.selectorDelegate = self
        
        let addBookButton = AddBookButton()
        addBookButton.delegate = self
        view.addSubview(addBookButton)
        
        NSLayoutConstraint.activate([
            libraryLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            libraryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bookSelector.topAnchor.constraint(equalTo: libraryLabel.topAnchor),
            bookSelector.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bookSelector.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bookSelector.heightAnchor.constraint(equalToConstant: 275),
            addBookButton.topAnchor.constraint(equalTo: bookSelector.bottomAnchor),
            addBookButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4.0)
        ])
    }
    
    @objc func pushReaderView() {
        //navigationController?.pushViewController(ReaderViewController(wordRepo: WordRepository(databaseManager: dbManager)), animated: true)
    }
}
