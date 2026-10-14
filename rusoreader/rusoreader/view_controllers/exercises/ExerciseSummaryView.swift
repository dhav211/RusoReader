import UIKit

class ExerciseSummaryView: UIViewController {
    override func viewDidLoad() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "COMPLETE"
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
