import Foundation
import SwiftUI

struct CatMeme: Identifiable, Codable, Equatable {
    let id: String
    let displayName: String
    let imageName: String
    let soundFileName: String
    let unlockCost: Int
    let pointsPerInteraction: Int
    let hapticProfile: HapticProfile
    let physicsProfile: PhysicsProfile
    let themeColor: ThemeColor
    let description: String
    
    static let allMemes: [CatMeme] = [
        CatMeme(
            id: "popcat",
            displayName: "Pop Cat",
            imageName: "popcat",
            soundFileName: "popcat_pop",
            unlockCost: 0,
            pointsPerInteraction: 1,
            hapticProfile: .pop,
            physicsProfile: .bouncy,
            themeColor: ThemeColor(red: 1.0, green: 0.7, blue: 0.8),
            description: "The legendary popper!"
        ),
        CatMeme(
            id: "bongocat",
            displayName: "Bongo Cat",
            imageName: "bongocat",
            soundFileName: "bongo_tap",
            unlockCost: 500,
            pointsPerInteraction: 5,
            hapticProfile: .rhythmic,
            physicsProfile: .balanced,
            themeColor: ThemeColor(red: 0.9, green: 0.6, blue: 0.4),
            description: "bongo bomboclat!"
        ),
        CatMeme(
            id: "huhcat",
            displayName: "Huh Cat",
            imageName: "huhcat",
            soundFileName: "huh_sound",
            unlockCost: 1000,
            pointsPerInteraction: 9,
            hapticProfile: .confused,
            physicsProfile: .stiff,
            themeColor: ThemeColor(red: 0.7, green: 0.8, blue: 0.9),
            description: "Huh?"
        ),
        CatMeme(
            id: "angrycat",
            displayName: "Angry Cat",
            imageName: "angrycat",
            soundFileName: "angry_mrrp",
            unlockCost: 5000,
            pointsPerInteraction: 12,
            hapticProfile: .aggressive,
            physicsProfile: .heavy,
            themeColor: ThemeColor(red: 0.9, green: 0.3, blue: 0.3),
            description: "GRRR!"
        ),
        CatMeme(
            id: "politecat",
            displayName: "Polite Cat",
            imageName: "politecat",
            soundFileName: "cry_meow",
            unlockCost: 10000,
            pointsPerInteraction: 20,
            hapticProfile: .soft,
            physicsProfile: .floaty,
            themeColor: ThemeColor(red: 0.6, green: 0.7, blue: 0.9),
            description: "look at that flat mouth of yours!"
        ),
        CatMeme(
            id: "widecat",
            displayName: "Wide Cat",
            imageName: "widecat",
            soundFileName: "wide_boop",
            unlockCost: 50000,
            pointsPerInteraction: 30,
            hapticProfile: .wobbly,
            physicsProfile: .wide,
            themeColor: ThemeColor(red: 0.8, green: 0.5, blue: 0.9),
            description: "He wide! He stretch!"
        ),
        CatMeme(
            id: "sillycat",
            displayName: "Silly Cat",
            imageName: "sillycat",
            soundFileName: "silly_blep",
            unlockCost: 100000,
            pointsPerInteraction: 50,
            hapticProfile: .playful,
            physicsProfile: .chaotic,
            themeColor: ThemeColor(red: 1.0, green: 0.9, blue: 0.4),
            description: "Just a little guy being silly"
        ),
        CatMeme(
            id: "corporatecat",
            displayName: "Corporate Cat",
            imageName: "corporatecat",
            soundFileName: "silly_blep",
            unlockCost: 200000,
            pointsPerInteraction: 100,
            hapticProfile: .playful,
            physicsProfile: .chaotic,
            themeColor: ThemeColor(red: 1.0, green: 0.9, blue: 0.4),
            description: "ready to work on tapping?"
        ),
        CatMeme(
            id: "cryingcat",
            displayName: "Crying Cat",
            imageName: "cryingcat",
            soundFileName: "silly_blep",
            unlockCost: 400000,
            pointsPerInteraction: 300,
            hapticProfile: .playful,
            physicsProfile: .chaotic,
            themeColor: ThemeColor(red: 1.0, green: 0.9, blue: 0.4),
            description: "sad :("
        ),
        CatMeme(
            id: "Rio",
            displayName: "Rio",
            imageName: "rio",
            soundFileName: "silly_blep",
            unlockCost: 0,
            pointsPerInteraction: 3000000,
            hapticProfile: .playful,
            physicsProfile: .chaotic,
            themeColor: ThemeColor(red: 1.0, green: 0.9, blue: 0.4),
            description: "The Great DeGenerous RIO!"
        )
    ]
}

struct ThemeColor: Codable, Equatable {
    let red: Double
    let green: Double
    let blue: Double
    
    var swiftUIColor: Color {
        Color(red: red, green: green, blue: blue)
    }
}
