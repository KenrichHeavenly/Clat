import Foundation
import SwiftUI

enum Constants {
    static let appName = "Clat"
    static let minOSVersion = "iOS 17.0"
    
    enum Physics {
        static let gravity: CGFloat = -5.0
        static let maxVelocity: CGFloat = 2000
        static let boundaryRestitution: CGFloat = 0.3
    }
    
    enum Gameplay {
        static let comboWindow: TimeInterval = 0.4
        static let maxCombo: Int = 20
        static let memeRainInterval: TimeInterval = 3.0
        static let maxRainNodes: Int = 15
    }
    
    enum Animation {
        static let defaultDuration: Double = 0.3
        static let springResponse: Double = 0.4
        static let springDamping: Double = 0.8
    }
}
