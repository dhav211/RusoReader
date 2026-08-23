import UIKit

/// A view controller that presents a flashcard-based language learning exercise.
///
/// This view controller displays a flashcard with a word on the front and translations with an example sentence on the back.
/// Users can flip the card to reveal the answer and rate their knowledge of the word.
class FlashcardExerciseView : UIViewController, Exercise {
    private let viewModel: FlashcardExerciseViewModel
    
    weak var completionDelegate: CompletedExerciseDelegate?
    
    private var card: UIView
    private var front: FlashcardFront
    private var back: FlashcardBack
    private var rating: FlashcardRating
    private var banner: ExerciseBanner

    private var frontCardConstraints = [NSLayoutConstraint]()
    private var backCardConstraints = [NSLayoutConstraint]()
    
    private var isFlipped = false
    
    init(viewModel: FlashcardExerciseViewModel) {
        self.viewModel = viewModel
        self.card = UIView()
        self.front = FlashcardFront(wordText: viewModel.getWordText())
        self.back = FlashcardBack(
            translations: viewModel.getTranslations(),
            sentence: FlashcardBack.AttributedSentence(
                text: viewModel.getSentence(),
                boldedRange: viewModel.getRangeOfBoldedText(viewModel.getSentence())
            ),
        )
        self.rating = FlashcardRating()
        self.banner = ExerciseBanner(text: "Do you know this word?")
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        // There are no constraints to change if we haven't flipped the card yet
        if !isFlipped { return }
        
        
        let orientation = PhoneOrientation.set(isViewInPortrait: view.window?.windowScene?.effectiveGeometry.interfaceOrientation.isPortrait)
        rating.reorientate(newOrientation: orientation)
        
        frontCardConstraints.forEach { constraint in
            constraint.isActive = true
        }
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        
        // The card view will hold the initial sizing so we can set constraints based on this
        card.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(banner)
        view.addSubview(card)
        card.addSubview(front)
        
        front.onFlipCard = flipCard
        
        NSLayoutConstraint.activate([
            banner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            banner.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            banner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            card.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            card.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.7),
            card.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.7),
            front.topAnchor.constraint(equalTo: card.topAnchor),
            front.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            front.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            front.trailingAnchor.constraint(equalTo: card.trailingAnchor)
        ])
    }
    
    private func flipCard() {
        if isFlipped {
            return
        }
        
        isFlipped = true
        guard let isPortrait = view.window?.windowScene?.interfaceOrientation.isPortrait else { return }
        
        backCardConstraints = [
            self.back.topAnchor.constraint(equalTo: self.card.topAnchor),
            self.back.bottomAnchor.constraint(equalTo: self.card.bottomAnchor),
            self.back.leadingAnchor.constraint(equalTo: self.card.leadingAnchor),
            self.back.trailingAnchor.constraint(equalTo: self.card.trailingAnchor)
        ]
        
        // these will be here instead of in the completion closure due to self issues
        let flashcardRatingConstraints =  FlashcardRating.Constraints(
                centerXAnchor: card.centerXAnchor,
                leadingAnchor: card.leadingAnchor,
                trailingAnchor: card.trailingAnchor,
                bottomAnchor: card.bottomAnchor,
                centerYAnchor: card.centerYAnchor
            )
        
        rating.onSendResult = { doesUserKnow in
            self.sendResult(doesUserKnow: doesUserKnow)
        }
        
        // Play the flip animation
        UIView.transition(with: card, duration: 0.6, options: .transitionFlipFromRight, animations: {
            self.front.removeFromSuperview()
            self.card.addSubview(self.back)

            self.backCardConstraints.forEach { constraint in
                constraint.isActive = true
            }
        }, completion: { [weak self] _ in // Once the animation has finished we will create the rating buttons
            if let rating = self?.rating {
                self?.view.addSubview(rating)
                rating.setup(isPortrait: isPortrait, constraints: flashcardRatingConstraints)
                // This is janky but the rating view itself needs a size for the buttons to actually be clickable
                // We could add this to flashcard rating constraints, and that would be logical but this works for the time being
                // aka forever
                if let view = self?.view {
                    NSLayoutConstraint.activate([
                        rating.topAnchor.constraint(equalTo: view.topAnchor),
                        rating.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                        rating.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                        rating.rightAnchor.constraint(equalTo: view.rightAnchor)
                    ])
                }
            }
        })
    }
    
    private func sendResult(doesUserKnow: Bool) {
        completionDelegate?.grade(result: viewModel.calculateResult(doesUserKnow))
        completionDelegate?.next()
    }
    
    @objc func runTTS() {
        print("running tts")
    }
}
