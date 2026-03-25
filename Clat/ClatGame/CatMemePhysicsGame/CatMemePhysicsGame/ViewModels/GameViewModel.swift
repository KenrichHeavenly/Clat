import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var currentScreen: AppScreen = .home
    @Published var gameState: GameState
    @Published var comboCount: Int = 0
    @Published var isComboActive: Bool = false
    @Published var lastInteractionTime: Date?
    
    private var comboTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    var currentMeme: CatMeme {
        CatMeme.allMemes.first { $0.id == gameState.selectedMemeID } ?? CatMeme.allMemes[0]
    }
    
    var unlockedMemes: [CatMeme] {
        CatMeme.allMemes.filter { gameState.unlockedMemeIDs.contains($0.id) }
    }
    
    var lockedMemes: [CatMeme] {
        CatMeme.allMemes.filter { !gameState.unlockedMemeIDs.contains($0.id) }
    }
    
    var canAffordNextUnlock: Bool {
        if let nextCheapest = lockedMemes.min(by: { $0.unlockCost < $1.unlockCost }) {
            return gameState.totalPoints >= nextCheapest.unlockCost
        }
        return false
    }
    
    init() {
        self.gameState = PersistenceManager.shared.loadGameState()
        syncManagers()
    }
    
    private func syncManagers() {
        AudioManager.shared.updateSettings(
            enabled: gameState.settings.soundEnabled,
            volume: gameState.settings.volume
        )
        HapticManager.shared.updateSettings(enabled: gameState.settings.hapticsEnabled)
    }
    
    // MARK: - Navigation
    
    func navigate(to screen: AppScreen) {
        currentScreen = screen
    }
    
    func goBack() {
        switch currentScreen {
        case .game, .collection, .settings:
            currentScreen = .home
        default:
            break
        }
    }
    
    // MARK: - Gameplay
    
    func recordInteraction(type: InteractionType = .tap) {
        let now = Date()
        
        if let lastTime = lastInteractionTime, now.timeIntervalSince(lastTime) < 0.4 {
            comboCount = min(comboCount + 1, 10)
            isComboActive = true
            
            comboTimer?.invalidate()
            comboTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.comboCount = 0
                    self?.isComboActive = false
                }
            }
            
            HapticManager.shared.playCombo(count: comboCount)
        } else {
            comboCount = 0
            isComboActive = false
            HapticManager.shared.playTap(for: currentMeme.hapticProfile)
        }
        
        lastInteractionTime = now
        
        let basePoints = currentMeme.pointsPerInteraction
        let comboMultiplier = 1 + (comboCount / 5)
        let points = basePoints * comboMultiplier * type.pointMultiplier
        
        gameState.totalPoints += points
        gameState.lifetimeInteractions += 1
        
        AudioManager.shared.playSound(named: currentMeme.soundFileName)
        
        saveGameState()
    }
    
    func recordThrow(velocity: CGFloat) {
        let intensity = min(velocity / 1000, 1.0)
        let bonusPoints = Int(intensity * 5)
        
        gameState.totalPoints += bonusPoints
        gameState.lifetimeInteractions += 1
        
        HapticManager.shared.playThrow(for: currentMeme.hapticProfile)
        AudioManager.shared.playSound(named: currentMeme.soundFileName)
        
        saveGameState()
    }

    @discardableResult
    func recordRainCatHit(impulse: CGFloat) -> Int {
        let base = currentMeme.pointsPerInteraction
        let impulseFactor = min(impulse / 10.0, 1.0)
        let bonus = max(1, Int(CGFloat(base) * (0.5 + impulseFactor * 1.5)))
        let comboMultiplier = 1 + (comboCount / 5)
        let points = bonus * comboMultiplier

        gameState.totalPoints += points
        gameState.lifetimeInteractions += 1

        if isComboActive {
            comboCount = min(comboCount + 1, 20)
        }

        saveGameState()
        return points
    }
    
    // MARK: - Collection
    
    func selectMeme(_ meme: CatMeme) {
        guard gameState.unlockedMemeIDs.contains(meme.id) else { return }
        gameState.selectedMemeID = meme.id
        saveGameState()
    }
    
    func unlockMeme(_ meme: CatMeme) -> Bool {
        guard !gameState.unlockedMemeIDs.contains(meme.id),
              gameState.totalPoints >= meme.unlockCost else {
            HapticManager.shared.playError()
            return false
        }
        
        gameState.totalPoints -= meme.unlockCost
        gameState.unlockedMemeIDs.append(meme.id)
        saveGameState()
        
        HapticManager.shared.playUnlock()
        AudioManager.shared.playSound(named: "unlock_celebration")
        
        return true
    }
    
    // MARK: - Settings
    
    func toggleSound() {
        gameState.settings.soundEnabled.toggle()
        AudioManager.shared.isEnabled = gameState.settings.soundEnabled
        saveGameState()
    }
    
    func toggleHaptics() {
        gameState.settings.hapticsEnabled.toggle()
        HapticManager.shared.isEnabled = gameState.settings.hapticsEnabled
        saveGameState()
    }
    
    func updateVolume(_ volume: Double) {
        gameState.settings.volume = volume
        AudioManager.shared.volume = volume
        saveGameState()
    }
    
    func togglePerformanceMode() {
        gameState.settings.performanceMode.toggle()
        saveGameState()
    }
    
    func resetProgress() {
        PersistenceManager.shared.resetProgress()
        gameState = .default
        syncManagers()
    }
    
    private func saveGameState() {
        PersistenceManager.shared.saveGameState(gameState)
    }
}

enum InteractionType {
    case tap
    case drag
    case throwing
    
    var pointMultiplier: Int {
        switch self {
        case .tap: return 1
        case .drag: return 1
        case .throwing: return 2
        }
    }
}
