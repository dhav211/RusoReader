import UIKit

/// Pushes view controllers onto a navigation controller. We are using this so we can avoid passing in massive amounts of services to every view controller. Here we just connect this with the associated delegate which we handle in extensions below. When the view controller should be created it will fire off the delegate and push the view controller on to the stack.
final class AppCoordinator {
    let navigationController: UINavigationController
    let viewControllerFactory: ViewControllerFactory
    
    init(navigationController: UINavigationController, viewControllerFactory: ViewControllerFactory) {
        self.navigationController = navigationController
        self.viewControllerFactory = viewControllerFactory
    }
    
    /// Used to set up the first view controller, the HomePage View Controller
    func launch() {
        let homepageController = viewControllerFactory.createHomePageController()
        homepageController.delegate = self
        homepageController.setBookSelectorDelegate(appCoordinator: self)
        navigationController.pushViewController(homepageController, animated: false)
    }
}

extension AppCoordinator : HomepageDelegate {
    func onOpenReviewWordsTapped() {
        navigationController.pushViewController(
            viewControllerFactory.createExerciseController(),
            animated: true
        )
    }
}

extension AppCoordinator : BookSelectorDelegate {
    func onOpenBookTapped(book: Book) {
        navigationController.pushViewController(
            viewControllerFactory.createReaderController(bookToOpen: book),
            animated: true
        )
    }
}
