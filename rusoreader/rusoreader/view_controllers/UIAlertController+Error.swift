import UIKit

extension UIAlertController {
    /// A simple alert that displays a message and opitionally a function can be ran when user clicks OK
    /// - Parameters:
    ///   - message: The message stating what went wrong
    ///   - action: A function that will be ran after the user clicks OK
    /// - Returns: An UIAlertController with a error message and OK button
    static func error(message: String, action: (() -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(
            title: "Something Went Wrong",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in
            action?()
        })
        return alert
    }
}
