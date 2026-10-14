struct RandomWordFormSelector {
    static func getRandomWordFormForExercise(from word: Word) -> WordForm? {
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