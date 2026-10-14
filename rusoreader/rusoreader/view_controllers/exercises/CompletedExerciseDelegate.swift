protocol CompletedExerciseDelegate: AnyObject {
    func grade(result: ExerciseResult)
    func next()
}
