struct Verb {
    let aspect: Aspect
    let partners: [String]
    
    init(dbVerb: DatabaseVerb) {
        self.aspect = Aspect(rawValue: dbVerb.aspect) ?? Aspect.both
        self.partners = dbVerb.partner.split(separator: ";").map { partner in
            return String(partner)
        }
    }
    
    enum Aspect : String {
        case both = "both"
        case imperfective = "imperfective"
        case perfective = "perfective"
    }
}
