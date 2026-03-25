import SwiftUI
import SpriteKit

// MARK: - SKView subclass that presents the scene exactly once after layout
final class GameSKView: SKView {
    var onReadyToPresent: ((CGSize) -> Void)?
    private var didPresent = false

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !didPresent,
              bounds.width > 0, bounds.height > 0,
              let onReadyToPresent else { return }
        didPresent = true
        onReadyToPresent(bounds.size)
    }
}

// MARK: - UIViewRepresentable

struct SpriteSceneContainer: UIViewRepresentable {
    let meme: CatMeme
    let onCatTapped: () -> Void
    let onCatThrown: (CGFloat) -> Void
    let onMemeRain:  () -> Void
    let onRainCatHit: (CGFloat) -> Int

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        let skView = GameSKView()
        skView.backgroundColor      = .clear
        skView.allowsTransparency   = true
        skView.showsFPS             = false
        skView.showsNodeCount       = false
        skView.preferredFramesPerSecond = 60
        skView.ignoresSiblingOrder  = true
        skView.translatesAutoresizingMaskIntoConstraints = false

        // This closure fires from layoutSubviews — exactly once, with real bounds
        skView.onReadyToPresent = { [weak coordinator = context.coordinator] size in
            coordinator?.presentScene(size: size)
        }

        container.addSubview(skView)
        NSLayoutConstraint.activate([
            skView.topAnchor.constraint(equalTo: container.topAnchor),
            skView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            skView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            skView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])

        context.coordinator.skView      = skView
        context.coordinator.pendingMeme = meme
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Only forward to the scene if the meme actually changed
        guard meme.id != context.coordinator.lastPresentedMemeID else { return }
        context.coordinator.pendingMeme = meme
        if let scene = context.coordinator.skView?.scene as? CatPhysicsScene {
            context.coordinator.lastPresentedMemeID = meme.id
            scene.updateCat(meme: meme)
        }
        // If scene isn't up yet pendingMeme will be used when layoutSubviews fires
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onCatTapped: onCatTapped, onCatThrown: onCatThrown,
                    onMemeRain: onMemeRain, onRainCatHit: onRainCatHit)
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, CatPhysicsSceneDelegate {
        let onCatTapped: () -> Void
        let onCatThrown: (CGFloat) -> Void
        let onMemeRain:  () -> Void
        let onRainCatHit: (CGFloat) -> Int

        weak var skView: GameSKView?
        var pendingMeme: CatMeme?
        var lastPresentedMemeID: String = ""

        private let wallImpact = UIImpactFeedbackGenerator(style: .rigid)

        init(onCatTapped: @escaping () -> Void,
             onCatThrown: @escaping (CGFloat) -> Void,
             onMemeRain:  @escaping () -> Void,
             onRainCatHit: @escaping (CGFloat) -> Int) {
            self.onCatTapped  = onCatTapped
            self.onCatThrown  = onCatThrown
            self.onMemeRain   = onMemeRain
            self.onRainCatHit = onRainCatHit
            wallImpact.prepare()
        }

        /// Called exactly once from GameSKView.layoutSubviews
        func presentScene(size: CGSize) {
            guard let skView, skView.scene == nil else { return }

            let scene = CatPhysicsScene(size: size)
            scene.scaleMode       = .resizeFill
            scene.backgroundColor = .clear
            scene.sceneDelegate   = self

            if let meme = pendingMeme {
                lastPresentedMemeID = meme.id
                scene.updateCat(meme: meme)
            }
            skView.presentScene(scene)
        }

        func catTapped()                  { onCatTapped() }
        func catThrown(velocity: CGFloat) { onCatThrown(velocity) }
        func spawnMemeRain()              { onMemeRain() }
        func catHitRainCat(impulse: CGFloat, completion: @escaping (Int) -> Void) {
            let points = onRainCatHit(impulse)
            completion(points)
            wallImpact.impactOccurred(intensity: min(0.4 + impulse * 0.02, 1.0))
            wallImpact.prepare()
        }

        func catHitWall() {
            wallImpact.impactOccurred(intensity: 0.5)
            wallImpact.prepare()
        }
    }
}

// MARK: - SwiftUI wrapper

struct SpriteSceneContainerView: View {
    @EnvironmentObject var viewModel: GameViewModel
    let onCatTapped: () -> Void
    let onCatThrown: (CGFloat) -> Void
    let onMemeRain:  () -> Void
    let onRainCatHit: (CGFloat) -> Int

    var body: some View {
        SpriteSceneContainer(
            meme:         viewModel.currentMeme,
            onCatTapped:  onCatTapped,
            onCatThrown:  onCatThrown,
            onMemeRain:   onMemeRain,
            onRainCatHit: onRainCatHit
        )
        .background(Color.clear)
    }
}
