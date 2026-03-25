import Foundation

struct GameState: Codable {
    var selectedMemeID: String
    var unlockedMemeIDs: [String]
    var totalPoints: Int
    var lifetimeInteractions: Int
    var settings: GameSettings

    static var `default`: GameState {
        GameState(
            selectedMemeID: "popcat",
            unlockedMemeIDs: ["popcat"],
            totalPoints: 0,
            lifetimeInteractions: 0,
            settings: GameSettings()
        )
    }
}

struct GameSettings: Codable {
    var soundEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var volume: Double = 0.8
    var performanceMode: Bool = false
}
