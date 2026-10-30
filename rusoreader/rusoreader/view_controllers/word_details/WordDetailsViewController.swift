import UIKit

class WordDetailsViewController: UIViewController {
    let viewModel: WordDetailsViewModel
    let speechSynth: SpeechSynth
    private var searchTask: Task<Void, Never>?
    private var loadingIndicator: UIActivityIndicatorView? = UIActivityIndicatorView()
    private let scrollView: UIScrollView
    private var wordDetailsStack: WordDetailsStackView? = nil
    private var hasSearchedDatabase = false // ensures the task will never run again
    
    init(viewModel: WordDetailsViewModel, speechSynth: SpeechSynth) {
        self.viewModel = viewModel
        self.speechSynth = speechSynth
        self.scrollView = UIScrollView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchTask?.cancel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if hasSearchedDatabase { return }
        
        searchTask = Task {
            await viewModel.findWord()
            
            hasSearchedDatabase = true
            
            loadingIndicator?.removeFromSuperview()
            loadingIndicator = nil
            
            if viewModel.foundWord {
                createWordDetailsStack()
                viewModel.addWordToDictionary()
            } else {
                // If nothing is found then right now just show a label saying that however we should offer a translation if ios version allows it
                createFailureLabel()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        view.addSubview(scrollView)
        
        setupLoadingIndicator()
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
        ])
    }
    
    private func setupLoadingIndicator() {
        guard let loadingIndicator else { return }
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.startAnimating()
        loadingIndicator.style = .large
        scrollView.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: scrollView.frameLayoutGuide.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: scrollView.frameLayoutGuide.centerYAnchor)
        ])
    }
    
    private func createWordDetailsStack() {
        wordDetailsStack = WordDetailsStackView(viewModel: viewModel, speechSynth: speechSynth)
        guard let wordDetailsStack else { return }

        scrollView.addSubview(wordDetailsStack)
            
        NSLayoutConstraint.activate([
                wordDetailsStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0),
                wordDetailsStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0),
                wordDetailsStack.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
                wordDetailsStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }
    
    private func createFailureLabel() {
        let failureLabel = UILabel()
        failureLabel.text = "Sorry \(viewModel.searchTerm) was not found in the database!"
        failureLabel.translatesAutoresizingMaskIntoConstraints = false
        failureLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        failureLabel.numberOfLines = 0
        failureLabel.textAlignment = .center
        
        scrollView.addSubview(failureLabel)
        
        NSLayoutConstraint.activate([
            failureLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            failureLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            failureLabel.centerYAnchor.constraint(equalTo: scrollView.frameLayoutGuide.centerYAnchor)
        ])
    }
}
