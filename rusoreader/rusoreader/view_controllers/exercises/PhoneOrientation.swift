enum PhoneOrientation {
    case landscape
    case portrait
    case error
    
    static func set(isViewInPortrait: Bool?) -> PhoneOrientation {
        if let isPortrait = isViewInPortrait {
            return isPortrait ? .portrait : .landscape
        }
        
        return .error  // Unlikely to ever hit this but lets cover our bases
    }
}
