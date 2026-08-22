class WordEndingFactory : ExerciseFactory {
    let word: Word
    let attempts: Int
    var wordForm: WordForm? = nil
    var hasWordForm: Bool { return wordForm != nil }
    private let wordService: WordService
    
    init(word: Word, wordService: WordService) {
        self.word = word
        self.attempts = 0
        self.wordService = wordService
        self.wordForm = getRandomWordFormForExercise(for: word)
    }
    
    func createExercise() -> (any Exercise)? {
        guard let wordForm = wordForm else { return nil }
        return WordEndingExerciseView(viewModel: WordEndingExerciseViewModel(word: word, wordForm: wordForm, wordService: wordService))
    }

    private func getRandomWordFormForExercise(for word: Word) -> WordForm? {
        var acceptedFormTypes: [Form] {
            if word.type == .adjective {
                return [
                    .adjectiveFemaleAccusative,
                    .adjectiveFemaleDative,
                    .adjectiveFemaleGenitive,
                    .adjectiveFemaleInstrumental,
                    .adjectiveFemalePrepositional,
                    .adjectiveMaleAccusative,
                    .adjectiveMaleDative,
                    .adjectiveMaleGenitive,
                    .adjectiveMaleInstrumental,
                    .adjectiveMalePrepositional,
                    .adjectiveNeuterAccusative,
                    .adjectiveNeuterDative,
                    .adjectiveNeuterGenitive,
                    .adjectiveNeuterInstrumental,
                    .adjectiveNeuterPrepositional,
                    .adjectivePluralAccusative,
                    .adjectivePluralDative,
                    .adjectivePluralGenitive,
                    .adjectivePluralInstrumental,
                    .adjectivePluralPrepositional,
                ]
            } else if word.type == .noun {
                return [
                    .nounSingularDative,
                    .nounSingularGenitive,
                    .nounSingularAccusative,
                    .nounSingularInstrumental,
                    .nounSingularPrepositional,
                    .nounPluralDative,
                    .nounPluralGenitive,
                    .nounPluralAccusative,
                    .nounPluralInstrumental,
                    .nounPluralPrepositional
                ]
            } else if word.type == .verb {
                return [
                    .verbPastMale,
                    .verbPastFemale,
                    .verbPastNeuter,
                    .verbPastPlural,
                    .verbPresentFuturePluralFirst,
                    .verbPresentFuturePluralSecond,
                    .verbPresentFuturePluralThird,
                    .verbPresentFutureSingularFirst,
                    .verbPresentFutureSingularSecond,
                    .verbPresentFutureSingularThird,
                ]
            } else {
                return []
            }
        }
        guard let randomFormType = acceptedFormTypes.randomElement() else { return nil }
        return word.forms.filter { $0.form == randomFormType }.first
    }
}
