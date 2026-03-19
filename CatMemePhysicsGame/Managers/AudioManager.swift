import AVFoundation
import SwiftUI
import Combine
class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    @Published var isEnabled: Bool = true
    @Published var volume: Double = 0.8
    
    private var audioPlayers: [AVAudioPlayer] = []
    private let maxPlayers = 12
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }
    
    func playSound(named soundName: String) {
        guard isEnabled else { return }
        
        if let player = audioPlayers.first(where: { !$0.isPlaying }) {
            player.volume = Float(volume)
            player.currentTime = 0
            player.play()
            return
        }
        
        if audioPlayers.count < maxPlayers {
            guard let url = findSoundURL(named: soundName) else {
                print("Sound not found: \(soundName)")
                return
            }
            
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.volume = Float(volume)
                player.prepareToPlay()
                audioPlayers.append(player)
                player.play()
            } catch {
                print("Failed to play sound: \(error)")
            }
        } else {
            if let oldestPlayer = audioPlayers.first {
                oldestPlayer.stop()
                oldestPlayer.currentTime = 0
                oldestPlayer.volume = Float(volume)
                oldestPlayer.play()
            }
        }
    }
    
    private func findSoundURL(named soundName: String) -> URL? {
        let extensions = ["wav", "mp3", "m4a", "caf"]
        for ext in extensions {
            if let url = Bundle.main.url(forResource: soundName, withExtension: ext) {
                return url
            }
        }
        return nil
    }
    
    func stopAllSounds() {
        audioPlayers.forEach { $0.stop() }
    }
    
    func updateSettings(enabled: Bool, volume: Double) {
        self.isEnabled = enabled
        self.volume = volume
    }
}
