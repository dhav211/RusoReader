import UIKit
import AVFAudio

final class ReadAlongToolbar: SpeechSynthObserver {
    private let speechSynth: SpeechSynth
    private let viewController: UIViewController
    private var isEnabled: Bool = false
    
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
    
    
    init(speechSynth: SpeechSynth, viewController: UIViewController) {
        self.speechSynth = speechSynth
        self.viewController = viewController
    
        speechSynth.addObserver(self)
        
        viewController.navigationController?.setToolbarHidden(true, animated: false)
    }
    
    deinit {
        speechSynth.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func enable() {
        isEnabled.toggle()
        
        // There may be times when the toolbar should be removed but not controlled
        guard let navigationController = viewController.navigationController else { return }
        if !isEnabled {
            if !navigationController.isToolbarHidden { navigationController.setToolbarHidden(true, animated: false) }
            if speechSynth.isSpeaking { speechSynth.stop() }
        }
    }
    
    @objc private func pause() {
        speechSynth.pause()
    }
    
    @objc private func stop() {
        speechSynth.stop()
    }
    
    func didSpeechSynthStart() {
        guard let navigationController = viewController.navigationController else { return }
        
        if isEnabled {
            viewController.setToolbarItems(pauseToolbarItems, animated: false)
            navigationController.setToolbarHidden(false, animated: true)
        }
    }
    
    func didSpeechSynthFinish() {
        guard let navigationController = viewController.navigationController else { return }
        
        if isEnabled {
            navigationController.setToolbarHidden(true, animated: true)
            enable()
        }
    }
    
    func didSpeechSynthPause() {
        if isEnabled {
            viewController.setToolbarItems(playToolbarItems, animated: false)
        }
    }
    
    func  didSpeechSynthContinue() {
        if isEnabled {
            viewController.setToolbarItems(pauseToolbarItems, animated: false)
        }
    }
}

