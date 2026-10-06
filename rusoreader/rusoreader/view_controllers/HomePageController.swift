import UIKit

protocol HomepageDelegate : AnyObject {
    func onOpenReviewWordsTapped()
    func onOpenSettingsTapped()
    func onOpenLibraryTapped()
}

class HomePageController: UIViewController, UIDocumentPickerDelegate {
    private let continueReading = ContinueReadingView()
    private let viewModel: HomePageViewModel
    
    weak var delegate: HomepageDelegate?
    
    init(viewModel: HomePageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(continueReading)
        
        // TODO Add a width to this, which should be 10% smaller than the width of the screen
        // The thing is we will have stats under the continue reading book but in landscape mode they will be the right
        
        NSLayoutConstraint.activate([
            continueReading.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            continueReading.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            continueReading.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
        
        toolbarItems = [
            UIBarButtonItem(image: UIImage(systemName: "books.vertical"), style: .plain, target: self, action: #selector(openLibraryTapped)),
            UIBarButtonItem(image: UIImage(systemName: "brain.head.profile"), style: .plain, target: self, action: #selector(openExerciseTapped)),
            UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(openSettingsTapped))
        ]
        
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        // Set the continue reading views book to the last read book, this may have change when coming back from the library
        guard let book = viewModel.lastOpenedBook else { return }
        continueReading.configure(for: book)
    }
    
    func setContinueReadingDelegate(appCoordinator: AppCoordinator) {
        continueReading.delegate = appCoordinator
    }
    
//    @objc func addBookButtonTapped() {
//        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.epub])
//        picker.delegate = self
//        picker.allowsMultipleSelection = false
//        present(picker, animated: true)
//    }
    
    @objc func openLibraryTapped() {
        delegate?.onOpenLibraryTapped()
    }
    
    @objc func openExerciseTapped() {
        delegate?.onOpenReviewWordsTapped()
    }
    
    @objc func openSettingsTapped() {
        delegate?.onOpenSettingsTapped()
    }
    
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//        do {
//            try viewModel.parseBooks(from: urls)
//        } catch {
//            print("Failed to parse book: \(error)")
//            // TODO display an alert message letting the user know there was an issue parsing the book
//        }
//    }
}
