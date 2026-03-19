import SwiftUI
import SpriteKit

struct SpriteSceneContainer: UIViewRepresentable {
    @ObservedObject var viewModel: GameViewModel
    let onCatTapped: () -> Void
    let onCatThrown: (CGFloat) -> Void
    let onMemeRain: () -> Void
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        skView.backgroundColor = .clear
        skView.allowsTransparency = true
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.preferredFramesPerSecond = 60
        
        let scene = CatPhysicsScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        scene.sceneDelegate = context.coordinator
        scene.updateCat(meme: viewModel.currentMeme)
        
        skView.presentScene(scene)
        
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        if let scene = uiView.scene as? CatPhysicsScene {
            scene.updateCat(meme: viewModel.currentMeme)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onCatTapped: onCatTapped, onCatThrown: onCatThrown, onMemeRain: onMemeRain)
    }
    
    class Coordinator: NSObject, CatPhysicsSceneDelegate {
        let onCatTapped: () -> Void
        let onCatThrown: (CGFloat) -> Void
        let onMemeRain: () -> Void
        
        init(onCatTapped: @escaping () -> Void, onCatThrown: @escaping (CGFloat) -> Void, onMemeRain: @escaping () -> Void) {
            self.onCatTapped = onCatTapped
            self.onCatThrown = onCatThrown
            self.onMemeRain = onMemeRain
        }
        
        func catTapped() {
            onCatTapped()
        }
        
        func catThrown(velocity: CGFloat) {
            onCatThrown(velocity)
        }
        
        func spawnMemeRain() {
            onMemeRain()
        }
    }
}
