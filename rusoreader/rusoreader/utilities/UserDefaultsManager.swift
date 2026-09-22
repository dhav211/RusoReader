import UIKit

struct UserDefaultsManager {
    static var textSize: Float {
        get {
            return Float(UserDefaults.standard.float(forKey: "textSize"))
        }
        set(newSize) {
            UserDefaults.standard.set(newSize, forKey: "textSize")
        }
    }
    
    static var defaultVoice: [String:Any]  {
        get {
            return UserDefaults.standard.dictionary(forKey: "defaultVoice") ?? ["": ""]
        }
        set(newVoice) {
            UserDefaults.standard.set(newVoice ,forKey: "defaultVoice")
        }
    }
    
    static var defaultLanguage: Language {
        get {
            guard let languageString = UserDefaults.standard.string(forKey: "defaultLanguage"),
                  let language = Language(rawValue: languageString) else {
                return .English // Default fallback
            }
            return language
        }
        set(newLanguage) {
            UserDefaults.standard.set(newLanguage.rawValue, forKey: "defaultLanguage")
        }
    }
}
