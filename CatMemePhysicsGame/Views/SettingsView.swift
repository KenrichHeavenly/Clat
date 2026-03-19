import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var showResetConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    viewModel.goBack()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text("Settings")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                Color.clear
                    .frame(width: 44, height: 44)
            }
            .padding()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Audio Section
                    SettingsSection(title: "Audio", icon: "speaker.wave.2") {
                        Toggle(isOn: Binding(
                            get: { viewModel.gameState.settings.soundEnabled },
                            set: { _ in viewModel.toggleSound() }
                        )) {
                            Text("Sound Effects")
                                .foregroundColor(.white)
                        }
                        .tint(viewModel.currentMeme.themeColor.swiftUIColor)
                        
                        if viewModel.gameState.settings.soundEnabled {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Volume")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    Image(systemName: "speaker.fill")
                                        .foregroundColor(.gray)
                                    Slider(
                                        value: Binding(
                                            get: { viewModel.gameState.settings.volume },
                                            set: { viewModel.updateVolume($0) }
                                        ),
                                        in: 0...1
                                    )
                                    .tint(viewModel.currentMeme.themeColor.swiftUIColor)
                                    Image(systemName: "speaker.wave.3.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                    
                    // Haptics Section
                    SettingsSection(title: "Haptics", icon: "iphone.radiowaves.left.and.right") {
                        Toggle(isOn: Binding(
                            get: { viewModel.gameState.settings.hapticsEnabled },
                            set: { _ in viewModel.toggleHaptics() }
                        )) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Haptic Feedback")
                                    .foregroundColor(.white)
                                Text("Vibration on interactions")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .tint(viewModel.currentMeme.themeColor.swiftUIColor)
                    }
                    
                    // Performance Section
                    SettingsSection(title: "Performance", icon: "bolt") {
                        Toggle(isOn: Binding(
                            get: { viewModel.gameState.settings.performanceMode },
                            set: { _ in viewModel.togglePerformanceMode() }
                        )) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Performance Mode")
                                    .foregroundColor(.white)
                                Text("Reduce particle effects")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .tint(viewModel.currentMeme.themeColor.swiftUIColor)
                    }
                    
                    // Stats Section
                    SettingsSection(title: "Statistics", icon: "chart.bar") {
                        StatRow(label: "Total Points", value: "\(viewModel.gameState.totalPoints)")
                        StatRow(label: "Interactions", value: "\(viewModel.gameState.lifetimeInteractions)")
                        StatRow(label: "Cats Unlocked", value: "\(viewModel.gameState.unlockedMemeIDs.count)/\(CatMeme.allMemes.count)")
                    }
                    
                    // Reset Section
                    SettingsSection(title: "Danger Zone", icon: "exclamationmark.triangle") {
                        Button(action: {
                            showResetConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Reset All Progress")
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    // About
                    VStack(spacing: 8) {
                        Text("Clat")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Version 1.0")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("Made with ❤️ for cat lovers")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 30)
                }
                .padding()
            }
        }
        .alert("Reset Progress?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                viewModel.resetProgress()
            }
        } message: {
            Text("This will erase all your points, unlocks, and progress. This cannot be undone!")
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                content
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.12, green: 0.12, blue: 0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
            )
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
}
