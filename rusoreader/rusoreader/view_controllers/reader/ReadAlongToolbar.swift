import UIKit
import AVFAudio

final class ReadAlongToolbar: SpeechSynthObserver {
    private weak var speechSynth: SpeechSynth?
    private weak var viewController: ReaderViewController?
    var isEnabled: Bool = false {
        didSet {
            // There may be times when the toolbar should be removed but the delegate functions won't be called to remove it, we will handle those cases here
            guard let viewController, let navigationController = viewController.navigationController, let speechSynth else { return }
            if !isEnabled {
                if !navigationController.isToolbarHidden { navigationController.setToolbarHidden(true, animated: true) }
                if speechSynth.isSpeaking { speechSynth.stop() }
            }
        }
    }
    
    private lazy var images: [String:UIImage?] = {
        let pauseImage = UIImage(systemName: "pause.circle.fill")
        let playImage = UIImage(systemName: "play.circle.fill")
        let stopImage = UIImage(systemName: "stop.circle.fill")
        return [
            "pause": pauseImage,
            "play": playImage,
            "stop": stopImage
        ]
    }()
    
    private lazy var pauseToolbarItems: [UIBarButtonItem] = {
        return [
            UIBarButtonItem(image: images["pause"] ?? UIImage(systemName: "circle"), style: .plain, target: self, action: #selector(pause)),
            UIBarButtonItem(image: images["stop"] ?? UIImage(systemName: "circle"), style: .plain, target: self, action: #selector(stop)),
        ]
    }()
    
    private lazy var playToolbarItems: [UIBarButtonItem] = {
        return [
            UIBarButtonItem(image: images["play"] ?? UIImage(systemName: "circle"), style: .plain, target: self, action: #selector(pause)),
            UIBarButtonItem(image: images["stop"] ?? UIImage(systemName: "circle"), style: .plain, target: self, action: #selector(stop)),
        ]
    }()
    
    
    init(speechSynth: SpeechSynth, viewController: ReaderViewController) {
        self.speechSynth = speechSynth
        self.viewController = viewController
    
        // The observer handles the function calls for the AVSpeechSynthsizerDelegate, as this and the reader will need to conform to it
        speechSynth.addObserver(self)
        
        viewController.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    deinit {
        guard let speechSynth else { return }
        speechSynth.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func pause() {
        guard let speechSynth else { return }
        speechSynth.pause()
    }
    
    @objc private func stop() {
        guard let speechSynth else { return }
        speechSynth.stop()
    }
    
    // The following functions are delegate functions from AVSpeechSynthsizerDelegate, they will manage the tool bar buttons state as the speech synth is running
    
    func didSpeechSynthStart() {
        guard let viewController, let navigationController = viewController.navigationController else { return }
        
        if isEnabled {
            viewController.setToolbarItems(pauseToolbarItems, animated: false)
            navigationController.setToolbarHidden(false, animated: true)
        }
    }
    
    func didSpeechSynthFinish() {
        isEnabled = false
    }
    
    func didSpeechSynthPause() {
        guard let viewController else { return }
        if isEnabled {
            viewController.setToolbarItems(playToolbarItems, animated: false)
        }
    }
    
    func  didSpeechSynthContinue() {
        guard let viewController else { return }
        if isEnabled {
            viewController.setToolbarItems(pauseToolbarItems, animated: false)
        }
    }
}

