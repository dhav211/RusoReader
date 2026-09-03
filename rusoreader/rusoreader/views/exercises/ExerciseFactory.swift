protocol ExerciseFactory {
    var word: Word { get }
    var attempts: Int { get set }
    func createExercise() -> Exercise?
}
