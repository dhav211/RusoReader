struct Noun {
    let gender: Gender
    let partner: String
    let animate: Bool
    let indeclinable: Bool
    let plurality: Plurality
    
    init(gender: Gender, partner: String, animate: Bool, indeclinable: Bool, plurality: Plurality) {
        self.gender = gender
        self.partner = partner
        self.animate = animate
        self.indeclinable = indeclinable
        self.plurality = plurality
    }
    
    init(dbNoun: DatabaseNoun) {
        self.gender = {
            switch dbNoun.gender {
            case "m":
                return Gender.male
            case "f":
                return Gender.female
            case "n":
                return Gender.neuter
            default:
                return Gender.both
            }
        }()
        
        self.partner = dbNoun.partner
        self.animate = dbNoun.animate.value
        self.indeclinable = dbNoun.indeclinable.value
        self.plurality = {
            if dbNoun.sg_only.value {
                return Plurality.singularOnly
            } else if dbNoun.pl_only.value {
                return Plurality.pluralOnly
            } else {
                return Plurality.neither
            }
        }()
    }
    
    enum Gender {
        case male
        case female
        case neuter
        case both
    }
    
    enum Plurality {
        case pluralOnly
        case singularOnly
        case neither
    }
}
