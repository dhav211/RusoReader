struct ExerciseResult {
    enum Grade {
        case correct
        case incorrect
        case almost
        case error
    }
    
    let word: Word
    let grade: Grade
    let score: Double
}
