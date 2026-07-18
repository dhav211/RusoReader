protocol Exercise {
    var completionDelegate: CompletedExerciseDelegate? { get set }
    func setup()
}
