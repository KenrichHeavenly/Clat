import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    
    private let defaults = UserDefaults.standard
    private let gameStateKey = "catMemePhysicsGameState"
    
    private init() {}
    
    func saveGameState(_ state: GameState) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(state)
            defaults.set(data, forKey: gameStateKey)
        } catch {
            print("Failed to save game state: \(error)")
        }
    }
    
    func loadGameState() -> GameState {
        guard let data = defaults.data(forKey: gameStateKey) else {
            return .default
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(GameState.self, from: data)
        } catch {
            print("Failed to load game state: \(error)")
            return .default
        }
    }
    
    func resetProgress() {
        defaults.removeObject(forKey: gameStateKey)
    }
}
