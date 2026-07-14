import UIKit

class ExerciseController : UIPageViewController {
    let dictionaryService: DictionaryService
    let wordService: WordService
    let sentenceService: SentenceService
    var coordinator: ExerciseCoordinator?
    
    init(dictionaryService: DictionaryService, wordService: WordService, sentenceService: SentenceService) {
        self.dictionaryService = dictionaryService
        self.wordService = wordService
        self.sentenceService = sentenceService
        
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        
        self.coordinator = ExerciseCoordinator(
            dictionaryService: dictionaryService,
            wordService: wordService,
            sentenceService: sentenceService,
            onLoadNextExercise: { [weak self] in self?.loadNextExercise() },
            onShowSummary: { [weak self] in self?.showSummary() }
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        guard let coordinator = coordinator else { return }
        
        guard let exercise = coordinator.nextExercise else { return }
        setViewControllers([exercise as! UIViewController], direction: .forward, animated: false)
    }
    
    private func loadNextExercise() {
        guard let coordinator = coordinator else { return }
        guard let exercise = coordinator.nextExercise else { return }
        setViewControllers([exercise as! UIViewController], direction: .forward, animated: true)
    }

    private func showSummary() {
        let summary = ExerciseSummaryView()
        setViewControllers([summary], direction: .forward, animated: true)
    }
}
