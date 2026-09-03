struct ExerciseWord {
    enum UserLevel {
        case new           // never seen
        case unfamiliar    // seen it, score is above normal
        case familiar      // seen it, score is low
        case fluent        // seen it many times, score is near zero
    }

    let id: Int
    let word: Word
    let userLevel: UserLevel

    init(word: Word, timesAppeared: Int, score: Double) {
        self.id = word.id
        self.word = word
        self.userLevel = Self.calculateUserLevel(timesAppeared: timesAppeared, score: score)
    }

    static func calculateUserLevel(timesAppeared: Int, score: Double) -> UserLevel {
        // User has never seen so it's cleary new
        if timesAppeared == 0 { return .new } 

        // User has encountered a few times and the score is low so send in a challenging exercise
        if timesAppeared > 3 && score < 1.0 { return .fluent }

        if score > 4 {
            return .unfamiliar
        } else {
            return .familiar
        }
    }
}

extension ExerciseWord: Hashable {
    static func == (lhs: ExerciseWord, rhs: ExerciseWord) -> Bool {
        lhs.id == rhs.id && lhs.userLevel == rhs.userLevel
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(userLevel)
    }
}