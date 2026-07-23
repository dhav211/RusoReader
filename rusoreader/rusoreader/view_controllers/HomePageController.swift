import UIKit

protocol HomepageDelegate : AnyObject {
    func onOpenReviewWordsTapped()
}

class HomePageController: UIViewController, UIDocumentPickerDelegate {
    private let bookSelector: BookSelectorViewController
    private let viewModel: HomePageViewModel
    
    weak var delegate: HomepageDelegate?
    
    init(viewModel: HomePageViewModel) {
        self.viewModel = viewModel
        self.bookSelector = viewModel.createBookSelector()
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
        
        addChild(bookSelector)
        view.addSubview(bookSelector.view)
        
        let addBookButton = UIButton()
        addBookButton.translatesAutoresizingMaskIntoConstraints = false
        addBookButton.setTitle("Add Book", for: .normal)
        addBookButton.setTitleColor(.label, for: .normal)
        addBookButton.addTarget(self, action: #selector(addBookButtonTapped), for: .touchUpInside)

        view.addSubview(addBookButton)
        
        let reviewWordsButton = UIButton()
        reviewWordsButton.translatesAutoresizingMaskIntoConstraints = false
        reviewWordsButton.setTitle("Review Words", for: .normal)
        reviewWordsButton.setTitleColor(.label, for: .normal)
        reviewWordsButton.addTarget(self, action: #selector(reviewWordsButtonTapped), for: .touchUpInside)
        view.addSubview(reviewWordsButton)
        
        NSLayoutConstraint.activate([
            libraryLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            libraryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bookSelector.view.topAnchor.constraint(equalTo: libraryLabel.topAnchor),
            bookSelector.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bookSelector.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bookSelector.view.heightAnchor.constraint(equalToConstant: 275),
            addBookButton.topAnchor.constraint(equalTo: bookSelector.view.bottomAnchor),
            addBookButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4.0),
            reviewWordsButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            reviewWordsButton.topAnchor.constraint(equalTo: addBookButton.bottomAnchor, constant: 5)
        ])
    }
    
    func setBookSelectorDelegate(appCoordinator: AppCoordinator) {
        bookSelector.selectorDelegate = appCoordinator
    }
    
    @objc func addBookButtonTapped() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.epub])
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }
    
    @objc func reviewWordsButtonTapped() {
        delegate?.onOpenReviewWordsTapped()
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        do {
            try viewModel.parseBooks(from: urls)
        } catch {
            print("Failed to parse book: \(error)")
            // TODO display an alert message letting the user know there was an issue parsing the book
        }
        
        bookSelector.refresh()
    }
}
