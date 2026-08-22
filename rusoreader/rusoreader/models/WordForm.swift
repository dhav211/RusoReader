struct WordForm {
    let bare: String
    let accented: String
    let form: Form

    var formText: String {
        switch form {
            case .adjectiveFemaleAccusative:
                return "Accusative in Female Form"
            case .adjectiveFemaleDative:
                return "Dative in Female Form"
            case .adjectiveFemaleGenitive:
                return "Genitive in Female Form"
            case .adjectiveFemaleInstrumental:
                return "Instrumental in Female Form"
            case .adjectiveFemalePrepositional:
                return "Prepositional in Female Form"
            case .adjectiveMaleAccusative:
                return "Accusative in Male Form"
            case .adjectiveMaleDative:
                return "Dative in Male Form"
            case .adjectiveMaleGenitive:
                return "Genitive in Male Form"
            case .adjectiveMaleInstrumental:
                return "Instrumental in Male Form"
            case .adjectiveMalePrepositional:
                return "Prepositional in Male Form"
            case .adjectiveNeuterAccusative:
                return "Accusative in Neuter Form"
            case .adjectiveNeuterDative:
                return "Dative in Neuter Form"
            case .adjectiveNeuterGenitive:
                return "Genitive in Neuter Form"
            case .adjectiveNeuterInstrumental:
                return "Instrumental in Neuter Form"
            case .adjectiveNeuterPrepositional:
                return "Prepositional in Neuter Form"
            case .adjectivePluralAccusative:
                return "Accusative in Plural Form"
            case .adjectivePluralDative:
                return "Dative in Plural Form"
            case .adjectivePluralGenitive:
                return "Genitive in Plural Form"
            case .adjectivePluralInstrumental:
                return "Instrumental in Plural Form"
            case .adjectivePluralPrepositional:
                return "Prepositional in Plural Form"
            case .nounSingularDative:
                return "Dative Singular"
            case .nounSingularGenitive:
                return "Genitive Singular"
            case .nounSingularAccusative:
                return "Accusative Singular"
            case .nounSingularInstrumental:
                return "Instrumental Singular"
            case .nounSingularPrepositional:
                return "Prepositional Singular"
            case .nounPluralDative:
                return "Dative Plural"
            case .nounPluralGenitive:
                return "Genitive Plural"
            case .nounPluralAccusative:
                return "Accusative Plural"
            case .nounPluralInstrumental:
                return "Instrumental Plural"
            case .nounPluralPrepositional:
                return "Prepositional Plural"
            case .verbPastMale:
                return "Past Tense, Masculine"
            case .verbPastFemale:
                return "Past Tense, Feminine"
            case .verbPastNeuter:
                return "Past Tense, Neuter"
            case .verbPastPlural:
                return "Past Tense, Plural"
            case .verbPresentFuturePluralFirst:
                return "Present/Future, We"
            case .verbPresentFuturePluralSecond:
                return "Present/Future, You (Plural)"
            case .verbPresentFuturePluralThird:
                return "Present/Future, They"
            case .verbPresentFutureSingularFirst:
                return "Present/Future, I"
            case .verbPresentFutureSingularSecond:
                return "Present/Future, You"
            case .verbPresentFutureSingularThird:
                return "Present/Future, He/She/It"
            case .adjectiveFemaleNominative:
                return "Nominative in Female Form"
            case .adjectiveMaleNominative:
                return "Nominative in Male Form"
            case .adjectiveNeuterNominative:
                return "Nominative in Neuter Form"
            case .adjectivePluralNominative:
                return "Nominative in Plural Form"
            case .adjectiveComparative:
                return "Comparative Form"
            case .adjectiveSuperlative:
                return "Superlative Form"
            case .adjectiveShortMale:
                return "Short Form, Masculine"
            case .adjectiveShortFemale:
                return "Short Form, Feminine"
            case .adjectiveShortNeuter:
                return "Short Form, Neuter"
            case .adjectiveShortPlural:
                return "Short Form, Plural"
            case .nounSingularNominative:
                return "Nominative Singular"
            case .nounPluralNominative:
                return "Nominative Plural"
            case .verbInfinitive:
                return "Verb Infinitive"
            case .base:
                return "Base Form"
            case .gerundPast:
                return "Gerund, Past"
            case .gerundPresent:
                return "Gerund, Present"
            case .verbImperativeSingular:
                return "Imperative, Singular"
            case .verbImperativePlural:
                return "Imperative, Plural"
            case .verbParticipleActivePast:
                return "Active Participle, Past"
            case .verbParticiplePassivePast:
                return "Passive Participle, Past"
            case .verbParticipleActivePresent:
                return "Active Participle, Present"
            case .verbParticiplePassivePresent:
                return "Passive Participle, Present"
            default:
                return "MISSING FORM TEXT FOR \(form.rawValue)"
        }
    }
}
