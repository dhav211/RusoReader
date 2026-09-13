import UIKit

protocol HomepageDelegate : AnyObject {
    func onOpenReviewWordsTapped()
    func onOpenSettingsTapped()
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
        
        toolbarItems = [
            UIBarButtonItem(image: UIImage(systemName: "books.vertical"), style: .plain, target: self, action: #selector(openLibraryTapped)),
            UIBarButtonItem(image: UIImage(systemName: "brain.head.profile"), style: .plain, target: self, action: #selector(openExerciseTapped)),
            UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(openSettingsTapped))
        ]
        
        navigationController?.setToolbarHidden(false, animated: true)
        
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
        
        NSLayoutConstraint.activate([
            libraryLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            libraryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bookSelector.view.topAnchor.constraint(equalTo: libraryLabel.topAnchor),
            bookSelector.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bookSelector.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bookSelector.view.heightAnchor.constraint(equalToConstant: 275),
            addBookButton.topAnchor.constraint(equalTo: bookSelector.view.bottomAnchor),
            addBookButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4.0)
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
    
    @objc func openLibraryTapped() {
        print("open the library")
    }
    
    @objc func openExerciseTapped() {
        delegate?.onOpenReviewWordsTapped()
    }
    
    @objc func openSettingsTapped() {
        delegate?.onOpenSettingsTapped()
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
