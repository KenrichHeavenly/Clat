import SpriteKit
import SwiftUI
import CoreMotion

protocol CatPhysicsSceneDelegate: AnyObject {
    func catTapped()
    func catThrown(velocity: CGFloat)
    func spawnMemeRain()
    func catHitRainCat(impulse: CGFloat, completion: @escaping (Int) -> Void)
    func catHitWall()
}

class CatPhysicsScene: SKScene {
    weak var sceneDelegate: CatPhysicsSceneDelegate?

    private var catNode: SKSpriteNode?
    private var catImageName: String = "popcat"
    private var physicsProfile: PhysicsProfile = .bouncy
    private var memeRainNodes: [SKSpriteNode] = []

    // Touch state
    private var touchStartLocation: CGPoint = .zero
    private var lastTouchLocation: CGPoint  = .zero
    private var touchStartTime: Date?
    private var isTouchingCat: Bool = false
    private var hasDragged: Bool    = false
    private let dragThreshold: CGFloat = 12.0

    private var hasSpawned = false
    private var currentMemeID: String = ""

    private let memeRainInterval: TimeInterval = 8.0   // slow background trickle only
    private var memeRainTimer: Timer?
    private var maxRainNodes = 15

    // MARK: - Gyroscope
    private let motionManager  = CMMotionManager()
    private let gravityStrength: CGFloat = 15.0

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        setupScene()
        setupBoundaries()
        startMemeRainTimer()
        startGyro()
    }

    override func willMove(from view: SKView) {
        stopMemeRain()
        stopGyro()
    }

    // MARK: - Gyro

    private func startGyro() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { [weak self] motion, _ in
            guard let self, let motion else { return }
            self.physicsWorld.gravity = CGVector(
                dx:  CGFloat(motion.gravity.x) * self.gravityStrength,
                dy:  CGFloat(motion.gravity.y) * self.gravityStrength
            )
        }
    }

    private func stopGyro() { motionManager.stopDeviceMotionUpdates() }

    // MARK: - Scene setup

    private func setupScene() {
        backgroundColor = .clear
        physicsWorld.gravity    = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
    }

    private func setupBoundaries() {
        let border = SKPhysicsBody(edgeLoopFrom: frame)
        border.friction          = 0.2
        border.restitution       = 0.3
        border.categoryBitMask   = 4        // wall = bitmask 4
        border.contactTestBitMask = 1       // notify when main cat (1) touches wall
        physicsBody = border
    }

    // MARK: - Cat management

    /// Only re-spawns when the meme actually changes. Safe to call repeatedly.
    func updateCat(meme: CatMeme) {
        guard meme.id != currentMemeID else { return }   // ← nothing changed, do nothing
        currentMemeID  = meme.id
        catImageName   = meme.imageName
        physicsProfile = meme.physicsProfile

        catNode?.removeFromParent()
        catNode    = nil
        hasSpawned = false

        guard frame.width > 0, frame.height > 0 else { return }
        spawnCat()
    }

    private func spawnCat() {
        guard !hasSpawned, frame.width > 0, frame.height > 0 else { return }

        let size: CGFloat = min(frame.width, frame.height) * 0.35
        guard size > 0 else { return }

        let cat: SKSpriteNode
        if let image = UIImage(named: catImageName) {
            cat = SKSpriteNode(texture: SKTexture(image: image))
        } else {
            cat = createPlaceholderCat(size: size)
        }

        cat.size     = CGSize(width: size, height: size)
        cat.position = CGPoint(x: frame.midX, y: frame.midY)
        cat.name     = "cat"

        cat.physicsBody = SKPhysicsBody(circleOfRadius: size * 0.4)
        cat.physicsBody?.restitution    = physicsProfile.restitution
        cat.physicsBody?.friction       = physicsProfile.friction
        cat.physicsBody?.density        = physicsProfile.density
        cat.physicsBody?.linearDamping  = physicsProfile.linearDamping
        cat.physicsBody?.angularDamping = physicsProfile.angularDamping
        cat.physicsBody?.allowsRotation = physicsProfile.allowsRotation
        cat.physicsBody?.mass           = physicsProfile.mass
        cat.physicsBody?.categoryBitMask    = 1
        cat.physicsBody?.contactTestBitMask = 2 | 4   // rain cats (2) + walls (4)
        cat.physicsBody?.collisionBitMask   = 0xFFFFFFFF

        addChild(cat)
        catNode    = cat
        hasSpawned = true
        addIdleAnimation(to: cat)
    }

    // MARK: - Placeholder cat

    private func createPlaceholderCat(size: CGFloat) -> SKSpriteNode {
        let container = SKSpriteNode(color: .clear, size: CGSize(width: size, height: size))

        let body = SKShapeNode(circleOfRadius: size * 0.35)
        body.fillColor  = UIColor.systemPink.withAlphaComponent(0.8)
        body.strokeColor = .clear
        body.position   = CGPoint(x: 0, y: -size * 0.05)
        container.addChild(body)

        for sign: CGFloat in [-1, 1] {
            let ear  = SKShapeNode()
            let path = CGMutablePath()
            path.move(to:     CGPoint(x: sign*size*0.15, y: size*0.15))
            path.addLine(to:  CGPoint(x: sign*size*0.25, y: size*0.35))
            path.addLine(to:  CGPoint(x: sign*size*0.05, y: size*0.25))
            path.closeSubpath()
            ear.path       = path
            ear.fillColor  = UIColor.systemPink.withAlphaComponent(0.8)
            ear.strokeColor = .clear
            container.addChild(ear)

            let eye = SKShapeNode(circleOfRadius: size * 0.06)
            eye.fillColor = .black
            eye.position  = CGPoint(x: sign * size * 0.12, y: 0)
            container.addChild(eye)
        }

        let nose = SKShapeNode(circleOfRadius: size * 0.03)
        nose.fillColor = UIColor.systemPink.withAlphaComponent(0.6)
        nose.position  = CGPoint(x: 0, y: -size * 0.08)
        container.addChild(nose)

        return container
    }

    // MARK: - Animations

    private func addIdleAnimation(to node: SKSpriteNode) {
        node.removeAction(forKey: "idle")
        node.run(SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 1.0),
            SKAction.scale(to: 0.95, duration: 1.0)
        ])), withKey: "idle")
    }

    private func playTapBounce(on node: SKSpriteNode) {
        node.removeAction(forKey: "idle")
        node.removeAction(forKey: "bounce")
        // Squash → big pop → settle, then resume idle
        let sequence = SKAction.sequence([
            SKAction.scale(to: 0.70, duration: 0.06),
            SKAction.scale(to: 1.35, duration: 0.10),
            SKAction.scale(to: 0.90, duration: 0.07),
            SKAction.scale(to: 1.10, duration: 0.05),
            SKAction.scale(to: 1.00, duration: 0.05),
            SKAction.run { [weak self, weak node] in
                guard let node else { return }
                self?.addIdleAnimation(to: node)
            }
        ])
        node.run(sequence, withKey: "bounce")
        // Small upward impulse so it feels physical
        node.physicsBody?.applyImpulse(CGVector(dx: 0, dy: (node.physicsBody?.mass ?? 1) * 80))
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let cat = catNode else { return }
        let loc = touch.location(in: self)

        // Expand hit area slightly (10pt padding) so edge-of-cat taps register
        let hitArea = cat.frame.insetBy(dx: -10, dy: -10)
        guard hitArea.contains(loc) else { return }

        isTouchingCat     = true
        hasDragged        = false
        touchStartLocation = loc
        lastTouchLocation  = loc
        touchStartTime     = Date()
        // Physics stay LIVE until we confirm a real drag
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isTouchingCat, let touch = touches.first, let cat = catNode else { return }
        let loc  = touch.location(in: self)
        let prev = touch.previousLocation(in: self)

        let totalDx = loc.x - touchStartLocation.x
        let totalDy = loc.y - touchStartLocation.y
        let totalDistance = sqrt(totalDx*totalDx + totalDy*totalDy)

        if !hasDragged {
            guard totalDistance > dragThreshold else { return }   // not a drag yet
            hasDragged = true
            cat.physicsBody?.isDynamic = false
            cat.removeAction(forKey: "idle")
            cat.removeAction(forKey: "bounce")
        }

        // Move cat with finger, add spin
        cat.position   = loc
        cat.zRotation += (loc.x - prev.x) * 0.01
        lastTouchLocation = loc
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isTouchingCat, let cat = catNode else { return }
        defer {
            isTouchingCat = false
            hasDragged    = false
        }

        cat.physicsBody?.isDynamic = true

        if hasDragged {
            // ── Throw — spawn a small burst of rain cats ──
            let vel = CGVector(
                dx: (lastTouchLocation.x - touchStartLocation.x) * 15,
                dy: (lastTouchLocation.y - touchStartLocation.y) * 15
            )
            if abs(vel.dx) > 50 || abs(vel.dy) > 50 {
                cat.physicsBody?.velocity        = vel
                cat.physicsBody?.angularVelocity = (lastTouchLocation.x - touchStartLocation.x) * 0.02
                sceneDelegate?.catThrown(velocity: sqrt(vel.dx*vel.dx + vel.dy*vel.dy))
                // Burst of 2-3 rain cats on throw
                let burst = Int.random(in: 2...3)
                for i in 0..<burst {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.08) { [weak self] in
                        self?.spawnRainCat()
                    }
                }
            }
            addIdleAnimation(to: cat)
        } else {
            // ── Tap — spawn exactly one rain cat ──
            sceneDelegate?.catTapped()
            playTapBounce(on: cat)
            spawnRainCat()
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        catNode?.physicsBody?.isDynamic = true
        isTouchingCat = false
        hasDragged    = false
        if let cat = catNode { addIdleAnimation(to: cat) }
    }

    // MARK: - Floating Points Text

    private func showFloatingPoints(_ points: Int, at position: CGPoint) {
        let tier: Int
        switch points {
        case 1...2:  tier = 1
        case 3...5:  tier = 2
        case 6...9:  tier = 3
        default:     tier = 4
        }

        let text:      String
        let fontSize:  CGFloat
        let textColor: UIColor

        switch tier {
        case 1:
            text      = "+\(points)"
            fontSize  = 16
            textColor = UIColor(red: 0.55, green: 0.95, blue: 1.00, alpha: 1.0) // soft cyan
        case 2:
            text      = "+\(points)"
            fontSize  = 19
            textColor = UIColor(red: 1.00, green: 0.75, blue: 0.25, alpha: 1.0) // warm amber
        case 3:
            text      = "+\(points)"
            fontSize  = 22
            textColor = UIColor(red: 1.00, green: 0.40, blue: 0.75, alpha: 1.0) // pink
        default:
            text      = "+\(points)"
            fontSize  = 26
            textColor = UIColor(red: 1.00, green: 0.90, blue: 0.20, alpha: 1.0) // gold
        }

        // Main label
        let label = SKLabelNode(text: text)
        label.fontName              = "ChalkboardSE-Bold"
        label.fontSize              = fontSize
        label.fontColor             = textColor
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center

        // Thin dark stroke for legibility — achieved with a shadow label behind
        let shadow = SKLabelNode(text: text)
        shadow.fontName               = "ChalkboardSE-Bold"
        shadow.fontSize               = fontSize
        shadow.fontColor              = UIColor.black.withAlphaComponent(0.45)
        shadow.verticalAlignmentMode  = .center
        shadow.horizontalAlignmentMode = .center
        shadow.position               = CGPoint(x: 0.8, y: -0.8)
        shadow.zPosition              = -1
        label.addChild(shadow)

        label.position  = position
        label.zPosition = 100
        label.alpha     = 0
        label.setScale(0.5)
        addChild(label)

        // Pop in
        let popIn  = SKAction.group([
            SKAction.fadeIn(withDuration: 0.07),
            SKAction.scale(to: 1.15, duration: 0.09)
        ])
        let settle = SKAction.scale(to: 1.0, duration: 0.06)

        // Float up with slight drift
        let drift   = CGFloat.random(in: -18...18)
        let floatUp = SKAction.moveBy(x: drift, y: 72, duration: 0.65)
        floatUp.timingMode = .easeOut

        let fadeOut = SKAction.fadeOut(withDuration: 0.22)
        let remove  = SKAction.removeFromParent()

        label.run(SKAction.sequence([
            SKAction.group([popIn]),
            settle,
            SKAction.wait(forDuration: 0.20),
            SKAction.group([
                floatUp,
                SKAction.sequence([
                    SKAction.wait(forDuration: 0.38),
                    fadeOut
                ])
            ]),
            remove
        ]))
    }


    private func startMemeRainTimer() {
        memeRainTimer?.invalidate()
        memeRainTimer = Timer.scheduledTimer(withTimeInterval: memeRainInterval, repeats: true) { [weak self] _ in
            self?.triggerMemeRain()
        }
    }

    func triggerMemeRain() {
        sceneDelegate?.spawnMemeRain()
        // Background trickle — just 1-2 cats every 8s
        let count = Int.random(in: 1...2)
        for i in 0..<count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) { [weak self] in
                self?.spawnRainCat()
            }
        }
    }

    private func spawnRainCat() {
        guard memeRainNodes.count < maxRainNodes, frame.width > 0 else {
            cleanupOldRainNodes(); return
        }
        let size = CGFloat.random(in: 35...65)
        let x    = CGFloat.random(in: 50...max(50, frame.width - 50))
        let rc   = createRainCatNode(size: size)
        rc.position  = CGPoint(x: x, y: frame.height + 50)
        rc.zRotation = CGFloat.random(in: -0.5...0.5)
        rc.alpha     = 0.75

        rc.physicsBody = SKPhysicsBody(circleOfRadius: size * 0.4)
        rc.physicsBody?.restitution      = CGFloat.random(in: 0.4...0.8)
        rc.physicsBody?.friction         = 0.3
        rc.physicsBody?.density          = 0.5
        rc.physicsBody?.categoryBitMask     = 2
        rc.physicsBody?.contactTestBitMask  = 1
        rc.physicsBody?.collisionBitMask    = 1

        addChild(rc)
        memeRainNodes.append(rc)

        rc.run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.fadeOut(withDuration: 2.0),
            SKAction.removeFromParent()
        ])) { [weak self] in self?.memeRainNodes.removeAll { $0 == rc } }
    }

    /// Creates a rain cat using the current meme image, falling back to placeholder
    private func createRainCatNode(size: CGFloat) -> SKSpriteNode {
        if let image = UIImage(named: catImageName) {
            // Use the actual meme image, same as the main cat
            let node = SKSpriteNode(texture: SKTexture(image: image))
            node.size = CGSize(width: size, height: size)
            return node
        } else {
            // Fallback placeholder
            let c = SKSpriteNode(color: .clear, size: CGSize(width: size, height: size))
            let b = SKShapeNode(circleOfRadius: size * 0.35)
            b.fillColor   = UIColor.systemPink.withAlphaComponent(0.6)
            b.strokeColor = .clear
            c.addChild(b)
            for sign: CGFloat in [-1, 1] {
                let e = SKShapeNode(circleOfRadius: size * 0.15)
                e.fillColor  = UIColor.systemPink.withAlphaComponent(0.6)
                e.position   = CGPoint(x: sign * size * 0.2, y: size * 0.25)
                c.addChild(e)
            }
            return c
        }
    }
    private func cleanupOldRainNodes() {
        while memeRainNodes.count > maxRainNodes / 2 {
            memeRainNodes.first?.removeFromParent()
            memeRainNodes.removeFirst()
        }
    }

    func stopMemeRain() {
        memeRainTimer?.invalidate()
        memeRainTimer = nil
    }
}

// MARK: - Physics Contact

extension CatPhysicsScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let maskA = contact.bodyA.categoryBitMask
        let maskB = contact.bodyB.categoryBitMask

        // Main cat (1) hit a rain cat (2)
        let isCatVsRain = (maskA == 1 && maskB == 2) || (maskA == 2 && maskB == 1)

        // Main cat (1) hit a wall (4)
        let isCatVsWall = (maskA == 1 && maskB == 4) || (maskA == 4 && maskB == 1)

        if isCatVsRain {
            let impulse = contact.collisionImpulse
            let contactPoint = contact.contactPoint

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                // Ask ViewModel for the exact points so label matches reality
                self.sceneDelegate?.catHitRainCat(impulse: impulse) { points in
                    self.showFloatingPoints(points, at: contactPoint)
                }
            }
            // Flash both the main cat and the rain cat
            let mainNode = maskA == 1 ? contact.bodyA.node : contact.bodyB.node
            let rainNode = maskA == 2 ? contact.bodyA.node : contact.bodyB.node
            if let n = mainNode as? SKSpriteNode { flashNode(n) }
            if let n = rainNode as? SKSpriteNode { flashNode(n) }
            // Pop the rain cat with a little scale burst
            rainNode?.run(SKAction.sequence([
                SKAction.scale(to: 1.4, duration: 0.06),
                SKAction.scale(to: 1.0, duration: 0.10)
            ]))
        } else if isCatVsWall {
            // Only fire haptic for meaningful wall hits, not gentle resting
            guard contact.collisionImpulse > 1.0 else { return }
            DispatchQueue.main.async { [weak self] in self?.sceneDelegate?.catHitWall() }
            let node = maskA == 1 ? contact.bodyA.node : contact.bodyB.node
            if let n = node as? SKSpriteNode { flashNode(n) }
        }
    }

    private func flashNode(_ node: SKSpriteNode) {
        node.run(SKAction.sequence([
            SKAction.colorize(with: .white, colorBlendFactor: 0.5, duration: 0.04),
            SKAction.colorize(withColorBlendFactor: 0,             duration: 0.08)
        ]))
    }
}
