/// Connected with the App Coordinator, this class is a way to reduce injecting all the services from view controller to view controller. Here the this class knows about the AppServices, which holds every service used in this app, and when the create view controller function is called then the AppServices is used to inject the services into the view controller.
final class ViewControllerFactory {
    let appServices: AppServices
    
    init(appServices: AppServices) {
        self.appServices = appServices
    }
    
    func createHomePageController() -> HomePageController {
        return HomePageController(viewModel: HomePageViewModel(bookService: appServices.bookService))
    }
    
    func createExerciseController() -> ExerciseController {
        return ExerciseController(
            dictionaryService: appServices.dictionaryService,
            wordService: appServices.wordService,
            sentenceService: appServices.sentenceService
        )
    }
    
    func createReaderController(bookToOpen: Book) -> ReaderViewController {
        let readerViewModel = ReaderViewModel(
            wordService: appServices.wordService,
            bookService: appServices.bookService,
            sentenceService: appServices.sentenceService,
            book: bookToOpen
        )
        
        return ReaderViewController(viewModel: readerViewModel)
    }
}
