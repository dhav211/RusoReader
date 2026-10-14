import UIKit

class ExerciseViewController: UIViewController {
    public var banner: ExerciseBanner
    public var exerciseArea: UIView
    public var submitButton: SubmitButton?
    public var completionBanner: ExerciseCompletionBanner?
    
    weak var completionDelegate: CompletedExerciseDelegate?

    init(banner: ExerciseBanner, submitButton: SubmitButton? = nil, completionBanner: ExerciseCompletionBanner? = nil) {
        self.banner = banner
        self.exerciseArea = UIView()
        self.submitButton = submitButton
        self.completionBanner = completionBanner
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setup() {
        view.backgroundColor = .systemBackground
        exerciseArea.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(banner)
        view.addSubview(exerciseArea)
        
        NSLayoutConstraint.activate([
            banner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            banner.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            banner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            exerciseArea.topAnchor.constraint(equalTo: banner.bottomAnchor),
            exerciseArea.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            exerciseArea.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            exerciseArea.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        
        if let completionBanner {
            addChild(completionBanner)
            view.addSubview(completionBanner.view)
            completionBanner.didMove(toParent: self)
            
            NSLayoutConstraint.activate([
                completionBanner.view.heightAnchor.constraint(equalToConstant: 200),
                completionBanner.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                completionBanner.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                completionBanner.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
        
        if let submitButton {
            view.addSubview(submitButton)
            NSLayoutConstraint.activate([
                submitButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32),
                submitButton.widthAnchor.constraint(equalToConstant: min((UIScreen.main.bounds.width) * 0.75, 300)),
                submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
        }
    }
}
