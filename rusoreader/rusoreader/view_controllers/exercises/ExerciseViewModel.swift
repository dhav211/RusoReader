protocol ExerciseViewModel {
    var word: Word { get }
    associatedtype AnswerInput
    func calculateResult(_ answer: AnswerInput) -> ExerciseResult
}
