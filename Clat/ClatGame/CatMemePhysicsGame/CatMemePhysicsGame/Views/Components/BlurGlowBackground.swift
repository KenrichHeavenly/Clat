import SwiftUI

struct BlurGlowBackground: View {
    let themeColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                themeColor.opacity(0.4),
                                themeColor.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width * 0.5
                        )
                    )
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .blur(radius: 60)
                
                // Secondary accent glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                themeColor.opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width * 0.6
                        )
                    )
                    .frame(width: geometry.size.width, height: geometry.size.width)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .blur(radius: 80)
                    .offset(x: 30, y: -20)
                
                // Bottom glow
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                themeColor.opacity(0.15),
                                Color.clear
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(width: geometry.size.width * 0.7, height: 100)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.85)
                    .blur(radius: 40)
            }
        }
    }
}

struct AnimatedGlow: View {
    let themeColor: Color
    @State private var isAnimating = false
    
    var body: some View {
        BlurGlowBackground(themeColor: themeColor)
            .scaleEffect(isAnimating ? 1.1 : 0.95)
            .opacity(isAnimating ? 1.0 : 0.7)
            .animation(
                .easeInOut(duration: 3).repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}
