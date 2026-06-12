import UIKit

class HomePageController: UIViewController, UIDocumentPickerDelegate {
    let bookService: BookService
    let wordService: WordService
    lazy var bookSelector: BookSelector = BookSelector(bookService: bookService)
    var isOnHomePage = true
    
    init(wordService: WordService, bookService: BookService) {
        self.wordService = wordService
        self.bookService = bookService
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
        
        let addBookButton = UIButton()
        addBookButton.translatesAutoresizingMaskIntoConstraints = false
        addBookButton.setTitle("Add Book", for: .normal)
        addBookButton.setTitleColor(.label, for: .normal)
        addBookButton.addTarget(self, action: #selector(addBookButtonTapped), for: .touchUpInside)

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
    
    override func viewWillAppear(_ animated: Bool) {
        isOnHomePage = true
    }
    
    @objc func addBookButtonTapped() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.epub])
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        do {
            for url in urls {
                try bookService.parseBook(from: url)
            }
        } catch {
            print("Failed to parse book: \(error)")
            // TODO display an alert message letting the user know there was an issue parsing the book
        }
        
        bookSelector.refresh()
    }
}
