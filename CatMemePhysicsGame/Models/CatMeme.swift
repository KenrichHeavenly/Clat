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
            description: "The legendary popper. Bouncy and snappy!"
        ),
        CatMeme(
            id: "bongocat",
            displayName: "Bongo Cat",
            imageName: "bongocat",
            soundFileName: "bongo_tap",
            unlockCost: 500,
            pointsPerInteraction: 2,
            hapticProfile: .rhythmic,
            physicsProfile: .balanced,
            themeColor: ThemeColor(red: 0.9, green: 0.6, blue: 0.4),
            description: "A musical prodigy with tiny drums. Rhythmic!"
        ),
        CatMeme(
            id: "huhcat",
            displayName: "Huh Cat",
            imageName: "huhcat",
            soundFileName: "huh_sound",
            unlockCost: 1000,
            pointsPerInteraction: 3,
            hapticProfile: .confused,
            physicsProfile: .stiff,
            themeColor: ThemeColor(red: 0.7, green: 0.8, blue: 0.9),
            description: "Confused feline with delayed reactions. Huh?"
        ),
        CatMeme(
            id: "angrycat",
            displayName: "Angry Cat",
            imageName: "angrycat",
            soundFileName: "angry_mrrp",
            unlockCost: 5000,
            pointsPerInteraction: 5,
            hapticProfile: .aggressive,
            physicsProfile: .heavy,
            themeColor: ThemeColor(red: 0.9, green: 0.3, blue: 0.3),
            description: "GRRR! Heavy and aggressive bounce."
        ),
        CatMeme(
            id: "cryingcat",
            displayName: "Crying Cat",
            imageName: "cryingcat",
            soundFileName: "cry_meow",
            unlockCost: 10000,
            pointsPerInteraction: 6,
            hapticProfile: .soft,
            physicsProfile: .floaty,
            themeColor: ThemeColor(red: 0.6, green: 0.7, blue: 0.9),
            description: "Emotional support needed. Soft and floaty."
        ),
        CatMeme(
            id: "widecat",
            displayName: "Wide Cat",
            imageName: "widecat",
            soundFileName: "wide_boop",
            unlockCost: 50000,
            pointsPerInteraction: 8,
            hapticProfile: .wobbly,
            physicsProfile: .wide,
            themeColor: ThemeColor(red: 0.8, green: 0.5, blue: 0.9),
            description: "He wide. He stretch. Exaggerated horizontal!"
        ),
        CatMeme(
            id: "sillycat",
            displayName: "Silly Cat",
            imageName: "sillycat",
            soundFileName: "silly_blep",
            unlockCost: 100000,
            pointsPerInteraction: 12,
            hapticProfile: .playful,
            physicsProfile: .chaotic,
            themeColor: ThemeColor(red: 1.0, green: 0.9, blue: 0.4),
            description: "Just a little guy being silly. Chaotic energy!"
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
