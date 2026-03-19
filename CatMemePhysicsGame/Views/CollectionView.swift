import SwiftUI

struct CollectionView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var showUnlockCelebration = false
    @State private var celebratedMeme: CatMeme?
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
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
                
                Text("Cat Collection")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                // Points display
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    Text("\(viewModel.gameState.totalPoints)")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }
            .padding()
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(CatMeme.allMemes) { meme in
                        MemeCardView(
                            meme: meme,
                            isUnlocked: viewModel.gameState.unlockedMemeIDs.contains(meme.id),
                            isSelected: viewModel.gameState.selectedMemeID == meme.id,
                            canAfford: viewModel.gameState.totalPoints >= meme.unlockCost
                        )
                        .onTapGesture {
                            handleMemeTap(meme)
                        }
                    }
                }
                .padding()
            }
        }
        .overlay {
            if showUnlockCelebration, let meme = celebratedMeme {
                UnlockCelebrationOverlay(meme: meme) {
                    withAnimation(.spring()) {
                        showUnlockCelebration = false
                        celebratedMeme = nil
                    }
                }
            }
        }
    }
    
    private func handleMemeTap(_ meme: CatMeme) {
        if viewModel.gameState.unlockedMemeIDs.contains(meme.id) {
            viewModel.selectMeme(meme)
            HapticManager.shared.playTap(for: .pop)
        } else {
            if viewModel.unlockMeme(meme) {
                celebratedMeme = meme
                withAnimation(.spring()) {
                    showUnlockCelebration = true
                }
            }
        }
    }
}

struct UnlockCelebrationOverlay: View {
    let meme: CatMeme
    let onComplete: () -> Void
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture(perform: onComplete)
            
            VStack(spacing: 24) {
                Text("🎉")
                    .font(.system(size: 60))
                
                Text("Unlocked!")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                MemeImageOrPlaceholder(imageName: meme.imageName, size: 120)
                    .shadow(color: meme.themeColor.swiftUIColor.opacity(0.6), radius: 20)
                
                Text(meme.displayName)
                    .font(.title2.bold())
                    .foregroundColor(meme.themeColor.swiftUIColor)
                
                Text(meme.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: onComplete) {
                    Text("Awesome!")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(meme.themeColor.swiftUIColor)
                        .cornerRadius(12)
                }
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 0.12, green: 0.12, blue: 0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(meme.themeColor.swiftUIColor.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}
