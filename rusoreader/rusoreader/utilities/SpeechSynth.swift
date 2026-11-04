import AVFoundation

enum SpeechSynthError: Error {
    case noInput
    case inputTooLarge
    case noVoice
}

protocol SpeechSynthObserver: AnyObject {
    func didSpeechSynthFinish()
    func didSpeechSynthPause()
    func didSpeechSynthStart()
    func didSpeechSynthContinue()
    func willSpeechSynthSpeakRange(range: NSRange)
}

final class SpeechSynth: NSObject {
    nonisolated(unsafe) private let synthesizer = AVSpeechSynthesizer()
    private let voice: AVSpeechSynthesisVoice?
    private let audioQueue = DispatchQueue(label: "speechsynth.audio-session") // for letting the speech synth be async
    private var isSessionActive = false   // only touched on audioQueue
    
    private let observers = NSHashTable<AnyObject>.weakObjects()
    
    var isPaused: Bool {
        return synthesizer.isPaused
    }
    
    var isSpeaking: Bool {
        return synthesizer.isSpeaking
    }

    override init() {
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
    
        super.init()
        
        synthesizer.delegate = self

        // Will handle bypassing the silent button, needs to be async because the compiler was making comments about it being on the main thread
        audioQueue.async { [weak self] in
            self?.activateSessionIfNeeded()
        }
    }

    /// Plays the given string through the on device apple TTS engine
    /// - Parameter content: A string value with the TTS will say aloud
    func speak(content: String, rate: Float) throws {
        guard let voice = voice else { throw SpeechSynthError.noVoice }
        
        synthesizer.stopSpeaking(at: .immediate)
        
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedContent.count > 100000 {
            throw SpeechSynthError.inputTooLarge
        } else if trimmedContent.count == 0 {
            throw SpeechSynthError.noInput
        }

        let utterance = AVSpeechUtterance(string: trimmedContent)
        utterance.voice = voice
        utterance.rate = rate
        utterance.pitchMultiplier = 1.0
        
        audioQueue.async { [weak self] in
            guard let self else { return }
            self.activateSessionIfNeeded()
            DispatchQueue.main.async {
                self.synthesizer.speak(utterance)
            }
        }
    }
    
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    func pause() {
        if !synthesizer.isPaused {
            synthesizer.pauseSpeaking(at: .immediate)
        } else {
            synthesizer.continueSpeaking()
        }
    }
    
    func addObserver(_ observer: SpeechSynthObserver) {
        observers.add(observer)
    }
    
    func removeObserver(_ observer: SpeechSynthObserver) {
        observers.remove(observer)
    }

    private func activateSessionIfNeeded() {
        guard !isSessionActive else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [])
            try session.setActive(true)
            isSessionActive = true
        } catch {
            print("Audio session error: \(error)")
        }
    }
    
    /// Set the first found with highest quality voice as the user default. This should happen in the SceneDelegate
    static func getDefaultVoice() -> [String:String] {
        // Grabs all russian downloaded voices
        let voices = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language == "ru-RU" }
            .sorted { $0.quality.rawValue > $1.quality.rawValue }
        
        guard let voice = voices.first else { return [:] }

        return [voice.identifier: voice.name]
    }
}

// These are the delegate functions from AVSpeechSynthesizerDelegate, here they will simply just call the observers which are added in other classes. The observers should primarily be the reader view controller for handling the karoke style hightlighting, and the read along tool bar for managing the pause/play/stop buttons
extension SpeechSynth: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        for case let observer as SpeechSynthObserver in observers.allObjects {
            observer.didSpeechSynthPause()
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        for case let observer as SpeechSynthObserver in observers.allObjects {
            observer.didSpeechSynthStart()
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        for case let observer as SpeechSynthObserver in observers.allObjects {
            observer.willSpeechSynthSpeakRange(range: characterRange)
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        for case let observer as SpeechSynthObserver in observers.allObjects {
            observer.didSpeechSynthFinish()
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        for case let observer as SpeechSynthObserver in observers.allObjects {
            observer.didSpeechSynthContinue()
        }
    }
}

// These are empty functions so any class that conforms to the observer doesn't need to implement every function
extension SpeechSynthObserver {
    func didSpeechSynthFinish() {}
    func didSpeechSynthPause() {}
    func didSpeechSynthStart() {}
    func didSpeechSynthContinue() {}
    func willSpeechSynthSpeakRange(range: NSRange) {}
}
