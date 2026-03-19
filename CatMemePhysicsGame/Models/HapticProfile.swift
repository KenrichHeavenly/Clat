import Foundation

enum HapticStyle: String, Codable {
    case light
    case soft
    case medium
    case rigid
    case heavy
    case selection
}

struct HapticProfile: Codable, Equatable {
    let style: HapticStyle
    let tapIntensity: Double
    let throwIntensity: Double
    let hasDoublePulse: Bool
    let hasRhythm: Bool

    // MARK: - Presets

    /// Pop Cat — snappy double pulse
    static let pop = HapticProfile(
        style: .medium,
        tapIntensity: 0.8,
        throwIntensity: 0.9,
        hasDoublePulse: true,
        hasRhythm: false
    )

    /// Bongo Cat — rhythmic tapping
    static let rhythmic = HapticProfile(
        style: .light,
        tapIntensity: 0.6,
        throwIntensity: 0.7,
        hasDoublePulse: false,
        hasRhythm: true
    )

    /// Huh Cat — soft and delayed
    static let confused = HapticProfile(
        style: .soft,
        tapIntensity: 0.4,
        throwIntensity: 0.5,
        hasDoublePulse: false,
        hasRhythm: false
    )

    /// Angry Cat — heavy impact
    static let aggressive = HapticProfile(
        style: .heavy,
        tapIntensity: 1.0,
        throwIntensity: 1.0,
        hasDoublePulse: false,
        hasRhythm: false
    )

    /// Crying Cat — gentle
    static let soft = HapticProfile(
        style: .soft,
        tapIntensity: 0.3,
        throwIntensity: 0.4,
        hasDoublePulse: false,
        hasRhythm: false
    )

    /// Wide Cat — wobbly double pulse
    static let wobbly = HapticProfile(
        style: .medium,
        tapIntensity: 0.6,
        throwIntensity: 0.7,
        hasDoublePulse: true,
        hasRhythm: false
    )

    /// Silly Cat — chaotic rhythm
    static let playful = HapticProfile(
        style: .light,
        tapIntensity: 0.7,
        throwIntensity: 0.8,
        hasDoublePulse: false,
        hasRhythm: true
    )
}
