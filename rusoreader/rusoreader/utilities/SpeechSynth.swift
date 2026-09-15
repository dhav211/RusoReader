import AVFoundation

enum SpeechSynthError: Error {
    case noInput
    case inputTooLarge
    case noVoice
}

final class SpeechSynth {
    private let synthesizer = AVSpeechSynthesizer()
    private let voice: AVSpeechSynthesisVoice?

    init() {
        // Grabs all russian downloaded voices 
        let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language == "ru-RU" }
        
        // Look into the user defaults and see if that user has default voice set
        let defaultVoiceDictionary = UserDefaultsManager.defaultVoice
        let identifier = defaultVoiceDictionary["identifier"] as? String
        let defaultVoice = identifier.flatMap { id in voices.first(where: { $0.identifier == id }) }
        
        // If the user has set a default voice then we can set that as the voice now
        if let defaultVoice, let index = voices.firstIndex(of: defaultVoice) {
            voice = voices[index]
        } else {
            // The user hasn't set a default voice yet so just grab the first one
            if let premium = voices.first(where: { $0.quality == .premium }) { // Premium actually doesn't exist for russian but maybe one day it will
                voice = premium
            } else if let enhanced = voices.first(where: { $0.quality == .enhanced }) {
                voice = enhanced
            } else {
                voice = voices.first
            }
        }

        // This bypasses the silent toggle on the side of the device
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }

    /// Plays the given string through the on device apple TTS engine
    /// - Parameter content: A string value with the TTS will say aloud
    func speak(content: String) throws {
        guard let voice = voice else { throw SpeechSynthError.noVoice }
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedContent.count > 1000 {
            throw SpeechSynthError.inputTooLarge
        } else if trimmedContent.count == 0 {
            throw SpeechSynthError.noInput
        }

        let utterance = AVSpeechUtterance(string: trimmedContent)
        utterance.voice = voice
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        synthesizer.speak(utterance)
    }
    
    /// Set the first found with highest quality voice as the user default. This should happen in the SceneDelegate
    static func setDefaultVoice() {
        // Grabs all russian downloaded voices
        let voices = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language == "ru-RU" }
            .sorted { $0.quality.rawValue > $1.quality.rawValue }
        
        guard let voice = voices.first else { return }

        
    }
}
