import SwiftUI

struct GalaxyBackgroundView: View {
    var body: some View {
        // 20fps is plenty for background — smooth but cheap
        TimelineView(.animation(minimumInterval: 1.0 / 20.0, paused: false)) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate
            GeometryReader { geo in
                ZStack {
                    // Deep space base — animated gradient shift
                    AnimatedBaseGradient(phase: phase)
                        .ignoresSafeArea()

                    // Drifting nebula clouds
                    NebulaLayer(phase: phase, size: geo.size)

                    // Triangle mesh
                    TriangleMeshLayer(phase: phase)

                    // Twinkling stars
                    StarsLayer(phase: phase, count: 70, size: geo.size)

                    // Vignette — static
                    RadialGradient(
                        colors: [.clear, .black.opacity(0.6)],
                        center: .center,
                        startRadius: geo.size.width * 0.25,
                        endRadius: geo.size.width * 0.85
                    )
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                }
            }
        }
    }
}

// MARK: - Animated base gradient (slow hue shift)
struct AnimatedBaseGradient: View {
    let phase: Double

    var body: some View {
        let hueShift = sin(phase * 0.05) * 0.03
        return LinearGradient(
            colors: [
                Color(hue: 0.67 + hueShift, saturation: 0.6, brightness: 0.10),
                Color(hue: 0.72 + hueShift, saturation: 0.5, brightness: 0.08),
                Color(hue: 0.62 + hueShift, saturation: 0.4, brightness: 0.12),
            ],
            startPoint: UnitPoint(
                x: 0.3 + sin(phase * 0.04) * 0.2,
                y: 0.0
            ),
            endPoint: UnitPoint(
                x: 0.7 + cos(phase * 0.03) * 0.2,
                y: 1.0
            )
        )
    }
}

// MARK: - Nebula drifting clouds
struct NebulaLayer: View {
    let phase: Double
    let size: CGSize

    var body: some View {
        ZStack {
            // Purple nebula — slow drift
            Circle()
                .fill(RadialGradient(
                    colors: [Color.purple.opacity(0.18), Color.clear],
                    center: .center, startRadius: 0,
                    endRadius: 180
                ))
                .frame(width: 360, height: 360)
                .offset(
                    x: sin(phase * 0.08) * 60,
                    y: cos(phase * 0.06) * 40 - size.height * 0.1
                )
                .blur(radius: 50)

            // Cyan nebula — different speed/direction
            Circle()
                .fill(RadialGradient(
                    colors: [Color.cyan.opacity(0.12), Color.clear],
                    center: .center, startRadius: 0,
                    endRadius: 150
                ))
                .frame(width: 300, height: 300)
                .offset(
                    x: cos(phase * 0.07) * -70,
                    y: sin(phase * 0.09) * 50 + size.height * 0.15
                )
                .blur(radius: 60)

            // Pink accent — faster, smaller
            Circle()
                .fill(RadialGradient(
                    colors: [Color.pink.opacity(0.10), Color.clear],
                    center: .center, startRadius: 0,
                    endRadius: 100
                ))
                .frame(width: 200, height: 200)
                .offset(
                    x: sin(phase * 0.12 + 1.0) * 80,
                    y: cos(phase * 0.10 + 2.0) * -60
                )
                .blur(radius: 45)

            // Blue deep nebula — very slow, large
            Circle()
                .fill(RadialGradient(
                    colors: [Color.indigo.opacity(0.14), Color.clear],
                    center: .center, startRadius: 0,
                    endRadius: 200
                ))
                .frame(width: 400, height: 400)
                .offset(
                    x: cos(phase * 0.04) * 50,
                    y: sin(phase * 0.05) * 80 + size.height * 0.3
                )
                .blur(radius: 70)
        }
    }
}

// MARK: - Triangle mesh
struct TriangleMeshLayer: View {
    let phase: Double

    var body: some View {
        Canvas { context, size in
            let gridSize: CGFloat = 90
            let cols = Int(size.width  / gridSize) + 2
            let rows = Int(size.height / gridSize) + 2

            for row in 0..<rows {
                for col in 0..<cols {
                    let baseX = CGFloat(col) * gridSize
                    let baseY = CGFloat(row) * gridSize

                    // Each vertex drifts independently
                    let ox = sin(Double(row) * 0.6 + phase * 0.15) * 14
                    let oy = cos(Double(col) * 0.5 + phase * 0.12) * 14

                    let p1 = CGPoint(x: baseX + ox,                   y: baseY + oy)
                    let p2 = CGPoint(x: baseX + gridSize + ox * 0.6,  y: baseY + gridSize * 0.35 + oy)
                    let p3 = CGPoint(x: baseX + gridSize * 0.35,      y: baseY + gridSize + oy * 0.6)

                    // Hue pulses slowly across the mesh
                    let hue        = 0.58 + 0.12 * sin(Double(row + col) * 0.25 + phase * 0.08)
                    let saturation = 0.35 + 0.20 * cos(Double(col) * 0.4 + phase * 0.05)
                    let brightness = 0.10 + 0.10 * sin(Double(row) * 0.5 + phase * 0.10)
                    let opacity    = 0.18 + 0.10 * sin(Double(row * col) * 0.1 + phase * 0.07)

                    let color = Color(hue: hue, saturation: saturation,
                                      brightness: brightness, opacity: opacity)

                    var path = Path()
                    path.move(to: p1)
                    path.addLine(to: p2)
                    path.addLine(to: p3)
                    path.closeSubpath()
                    context.fill(path, with: .color(color))
                    context.stroke(path, with: .color(color.opacity(0.4)), lineWidth: 0.5)
                }
            }
        }
    }
}

// MARK: - Twinkling stars
struct StarsLayer: View {
    let phase: Double
    let count: Int
    let size: CGSize

    var body: some View {
        Canvas { context, size in
            for i in 0..<count {
                let seed = Double(i)
                // Position drifts very slowly
                let x = (sin(seed * 1.31 + phase * 0.02) * 0.4 + 0.5) * size.width
                let y = (cos(seed * 0.73 + phase * 0.015) * 0.4 + 0.5) * size.height

                // Twinkle: brightness oscillates at different rates per star
                let twinkle  = 0.25 + 0.55 * abs(sin(seed * 0.9 + phase * (0.8 + seed.truncatingRemainder(dividingBy: 1.5))))
                let starSize = 1.2 + 2.2 * abs(sin(seed * 0.47))

                var path = Path()
                path.addEllipse(in: CGRect(
                    x: x - starSize / 2, y: y - starSize / 2,
                    width: starSize, height: starSize
                ))
                context.fill(path, with: .color(.white.opacity(twinkle)))

                // Larger stars get a soft glow
                if starSize > 2.5 {
                    var glowPath = Path()
                    let glowR = starSize * 2.5
                    glowPath.addEllipse(in: CGRect(
                        x: x - glowR / 2, y: y - glowR / 2,
                        width: glowR, height: glowR
                    ))
                    context.fill(glowPath, with: .color(.white.opacity(twinkle * 0.15)))
                }
            }
        }
    }
}
