protocol ExerciseFactory {
    var word: Word { get }
    var attempts: Int { get }
    func createExercise() -> Exercise?
}
