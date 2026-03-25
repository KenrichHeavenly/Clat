import SwiftUI

struct GameView: View {
    @EnvironmentObject var viewModel: GameViewModel

    var body: some View {
        ZStack {
            GalaxyBackgroundView()
                .ignoresSafeArea()

            AnimatedGlow(themeColor: viewModel.currentMeme.themeColor.swiftUIColor)
                .ignoresSafeArea()

            // SpriteSceneContainerView reads viewModel via @EnvironmentObject internally
            // so only re-renders when currentMeme changes, NOT when points change
            SpriteSceneContainerView(
                onCatTapped: { viewModel.recordInteraction(type: .tap) },
                onCatThrown: { velocity in viewModel.recordThrow(velocity: velocity) },
                onMemeRain:  { },
                onRainCatHit: { impulse in viewModel.recordRainCatHit(impulse: impulse) }
            )
            .ignoresSafeArea()

            // HUD
            VStack {
                HStack {
                    Button(action: { viewModel.goBack() }) {
                        Image(systemName: "xmark")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }

                    Spacer()

                    VStack(spacing: 4) {
                        Text(viewModel.currentMeme.displayName)
                            .font(.headline.bold())
                            .foregroundColor(.white)
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            Text("\(viewModel.gameState.totalPoints)")
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                        }
                    }

                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                Spacer()

                if viewModel.isComboActive && viewModel.comboCount > 2 {
                    Text("\(viewModel.comboCount)x TAPPING COMBO!")
                        .font(.title2.bold())
                        .foregroundColor(.orange)
                        .shadow(color: .orange.opacity(0.5), radius: 10)
                        .transition(.scale.combined(with: .opacity))
                        .padding(.bottom, 100)
                }

                VStack(spacing: 8) {
                    Text("Tap • Drag • Throw")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("+\(viewModel.currentMeme.pointsPerInteraction) per tap")
                        .font(.caption2)
                        .foregroundColor(viewModel.currentMeme.themeColor.swiftUIColor)
                }
                .padding(.bottom, 30)
            }
        }
    }
}
