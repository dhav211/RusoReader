import UIKit

class ExerciseController : UIPageViewController {
    let dictionaryService: DictionaryService
    let wordService: WordService
    let sentenceService: SentenceService
    let coordinator: ExerciseCoordinator
    
    init(dictionaryService: DictionaryService, wordService: WordService, sentenceService: SentenceService) {
        self.dictionaryService = dictionaryService
        self.wordService = wordService
        self.sentenceService = sentenceService
        self.coordinator = ExerciseCoordinator(dictionaryService: dictionaryService, wordService: wordService, sentenceService: sentenceService)
        
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        
        coordinator.onLoadNextExercise = { [weak self] in self?.loadNextExercise() }
        coordinator.onShowSummary = { [weak self] in self?.showSummary() }
        coordinator.createExercises()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        guard let exercise = coordinator.nextExercise else { return }
        setViewControllers([exercise as! UIViewController], direction: .forward, animated: false)
    }
    
    private func loadNextExercise() {
        guard let exercise = coordinator.nextExercise else { return }
        setViewControllers([exercise as! UIViewController], direction: .forward, animated: true)
    }

    private func showSummary() {
        let summary = ExerciseSummaryView()
        setViewControllers([summary], direction: .forward, animated: true)
    }
}
