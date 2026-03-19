import SwiftUI

struct MemeCardView: View {
    let meme: CatMeme
    let isUnlocked: Bool
    let isSelected: Bool
    let canAfford: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Image area
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isUnlocked
                        ? meme.themeColor.swiftUIColor.opacity(0.15)
                        : (canAfford ? Color.yellow.opacity(0.1) : Color.gray.opacity(0.1))
                    )
                
                if isUnlocked {
                    MemeImageOrPlaceholder(imageName: meme.imageName, size: 70)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 35))
                        .foregroundColor(canAfford ? .orange.opacity(0.7) : .gray.opacity(0.5))
                }
                
                if isSelected {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(.green)
                                .background(Circle().fill(.black))
                        }
                        Spacer()
                    }
                    .padding(8)
                }
            }
            .frame(height: 100)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.green.opacity(0.8) : (isUnlocked ? meme.themeColor.swiftUIColor.opacity(0.3) : Color.clear),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            
            // Info
            VStack(spacing: 4) {
                Text(meme.displayName)
                    .font(.subheadline.bold())
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                
                if isUnlocked {
                    HStack(spacing: 4) {
                        Image(systemName: "hand.tap.fill")
                            .font(.caption)
                        Text("+\(meme.pointsPerInteraction)")
                            .font(.caption)
                    }
                    .foregroundColor(meme.themeColor.swiftUIColor)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text("\(meme.unlockCost)")
                            .font(.caption.bold())
                            .foregroundColor(canAfford ? .orange : .gray)
                    }
                }
                
                Text(meme.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? meme.themeColor.swiftUIColor.opacity(0.5) : Color.white.opacity(0.05), lineWidth: 1)
                )
        )
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

struct MemeImageOrPlaceholder: View {
    let imageName: String
    let size: CGFloat
    
    var body: some View {
        Group {
            if UIImage(named: imageName) != nil {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
            } else {
                ZStack {
                    Circle()
                        .fill(Color.pink.opacity(0.2))
                    
                    Image(systemName: "cat.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.pink)
                        .padding(size * 0.2)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
