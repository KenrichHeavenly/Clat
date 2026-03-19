import UIKit
import CoreHaptics
import SwiftUI
import Combine

class HapticManager: ObservableObject {
    static let shared = HapticManager()
    
    @Published var isEnabled: Bool = true
    
    private var engine: CHHapticEngine?
    private var supportsCoreHaptics: Bool = false
    
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let softImpact = UIImpactFeedbackGenerator(style: .soft)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()
    
    private init() {
        prepareHaptics()
        setupCoreHaptics()
    }
    
    private func prepareHaptics() {
        lightImpact.prepare()
        softImpact.prepare()
        mediumImpact.prepare()
        rigidImpact.prepare()
        heavyImpact.prepare()
        selection.prepare()
        notification.prepare()
    }
    
    private func setupCoreHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            supportsCoreHaptics = true
        } catch {
            print("Core Haptics setup failed: \(error)")
        }
    }
    
    func playTap(for profile: HapticProfile) {
        guard isEnabled else { return }
        
        if profile.hasDoublePulse {
            playDoublePulse()
            return
        }
        
        if profile.hasRhythm {
            playRhythmicTap()
            return
        }
        
        switch profile.style {
        case .light:
            lightImpact.impactOccurred(intensity: CGFloat(profile.tapIntensity))
        case .soft:
            softImpact.impactOccurred(intensity: CGFloat(profile.tapIntensity))
        case .medium:
            mediumImpact.impactOccurred(intensity: CGFloat(profile.tapIntensity))
        case .rigid:
            rigidImpact.impactOccurred(intensity: CGFloat(profile.tapIntensity))
        case .heavy:
            heavyImpact.impactOccurred(intensity: CGFloat(profile.tapIntensity))
        case .selection:
            selection.selectionChanged()
        }
        
        prepareHaptics()
    }
    
    func playThrow(for profile: HapticProfile) {
        guard isEnabled else { return }
        
        let intensity = CGFloat(profile.throwIntensity)
        
        switch profile.style {
        case .light, .soft:
            mediumImpact.impactOccurred(intensity: intensity)
        case .medium:
            rigidImpact.impactOccurred(intensity: intensity)
        case .rigid, .heavy:
            heavyImpact.impactOccurred(intensity: intensity)
        case .selection:
            rigidImpact.impactOccurred(intensity: intensity)
        }
        
        prepareHaptics()
    }
    
    func playCombo(count: Int) {
        guard isEnabled else { return }
        
        let intensity = min(CGFloat(count) * 0.15, 1.0)
        
        if count >= 5 && count % 5 == 0 {
            notification.notificationOccurred(.success)
        } else {
            lightImpact.impactOccurred(intensity: intensity)
        }
        
        prepareHaptics()
    }
    
    func playUnlock() {
        guard isEnabled else { return }
        notification.notificationOccurred(.success)
    }
    
    func playError() {
        guard isEnabled else { return }
        notification.notificationOccurred(.error)
    }
    
    private func playDoublePulse() {
        guard supportsCoreHaptics, let engine = engine else {
            selection.selectionChanged()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.selection.selectionChanged()
            }
            return
        }
        
        var events: [CHHapticEvent] = []
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
        
        events.append(CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0))
        events.append(CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0.15))
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            selection.selectionChanged()
        }
    }
    
    private func playRhythmicTap() {
        lightImpact.impactOccurred(intensity: 0.4)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.lightImpact.impactOccurred(intensity: 0.3)
        }
        prepareHaptics()
    }
    
    func updateSettings(enabled: Bool) {
        self.isEnabled = enabled
    }
}
