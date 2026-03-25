import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Title
            VStack(spacing: 8) {
                Text("🐈")
                    .font(.system(size: 60))
                
                Text("Clat")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Tap. Drag. Throw.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 30)
            
            // Cat preview with glow
            ZStack {
                AnimatedGlow(themeColor: viewModel.currentMeme.themeColor.swiftUIColor)
                
                CatImageView(imageName: viewModel.currentMeme.imageName, size: 180)
                    .shadow(color: viewModel.currentMeme.themeColor.swiftUIColor.opacity(0.5), radius: 20)
            }
            .frame(height: 220)
            .padding(.bottom, 20)
            
            // Stats
            HStack(spacing: 40) {
                StatItem(value: "\(viewModel.gameState.totalPoints)", label: "Points")
                StatItem(value: "\(viewModel.gameState.lifetimeInteractions)", label: "Interactions")
            }
            .padding(.bottom, 40)
            
            Spacer()
            
            // Buttons
            VStack(spacing: 16) {
                Button(action: {
                    viewModel.navigate(to: .game)
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Play")
                    }
                    .font(.title3.bold())
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [viewModel.currentMeme.themeColor.swiftUIColor, viewModel.currentMeme.themeColor.swiftUIColor.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
                
                HStack(spacing: 16) {
                    Button(action: {
                        viewModel.navigate(to: .collection)
                    }) {
                        VStack {
                            Image(systemName: "square.grid.2x2")
                                .font(.title3)
                            Text("Cats")
                                .font(.caption.bold())
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                    }
                    
                    Button(action: {
                        viewModel.navigate(to: .settings)
                    }) {
                        VStack {
                            Image(systemName: "gearshape")
                                .font(.title3)
                            Text("Settings")
                                .font(.caption.bold())
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
    }
}

struct CatImageView: View {
    let imageName: String
    let size: CGFloat
    
    var body: some View {
        Group {
            if UIImage(named: imageName) != nil {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
            } else {
                // Fallback to SF Symbol cat
                ZStack {
                    Circle()
                        .fill(Color.pink.opacity(0.3))
                    
                    Image(systemName: "cat.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.pink)
                        .padding(size * 0.15)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct StatItem: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
