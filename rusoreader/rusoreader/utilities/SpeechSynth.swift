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

        // TODO this currently selects the first but we really need it do grab the user default voice they have downloaded and chosen, this works for now
        if let premium = voices.first(where: { $0.quality == .premium }) { // Premium actually doesn't exist for russian but maybe one day it will
            voice = premium
        } else if let enhanced = voices.first(where: { $0.quality == .enhanced }) {
            voice = enhanced
        } else {
            voice = voices.first
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
}
