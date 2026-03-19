import Foundation

struct PhysicsProfile: Codable, Equatable {
    let restitution: CGFloat
    let friction: CGFloat
    let density: CGFloat
    let linearDamping: CGFloat
    let angularDamping: CGFloat
    let allowsRotation: Bool
    let mass: CGFloat
    
    static let bouncy = PhysicsProfile(
        restitution: 0.8,
        friction: 0.3,
        density: 1.0,
        linearDamping: 0.1,
        angularDamping: 0.1,
        allowsRotation: true,
        mass: 1.0
    )
    
    static let balanced = PhysicsProfile(
        restitution: 0.5,
        friction: 0.4,
        density: 1.2,
        linearDamping: 0.2,
        angularDamping: 0.2,
        allowsRotation: true,
        mass: 1.2
    )
    
    static let stiff = PhysicsProfile(
        restitution: 0.3,
        friction: 0.6,
        density: 2.0,
        linearDamping: 0.4,
        angularDamping: 0.5,
        allowsRotation: true,
        mass: 2.0
    )
    
    static let heavy = PhysicsProfile(
        restitution: 0.4,
        friction: 0.5,
        density: 3.0,
        linearDamping: 0.3,
        angularDamping: 0.3,
        allowsRotation: true,
        mass: 3.0
    )
    
    static let floaty = PhysicsProfile(
        restitution: 0.6,
        friction: 0.2,
        density: 0.5,
        linearDamping: 0.05,
        angularDamping: 0.05,
        allowsRotation: true,
        mass: 0.5
    )
    
    static let wide = PhysicsProfile(
        restitution: 0.5,
        friction: 0.35,
        density: 1.5,
        linearDamping: 0.15,
        angularDamping: 0.2,
        allowsRotation: true,
        mass: 1.5
    )
    
    static let chaotic = PhysicsProfile(
        restitution: 0.9,
        friction: 0.1,
        density: 0.8,
        linearDamping: 0.05,
        angularDamping: 0.02,
        allowsRotation: true,
        mass: 0.8
    )
}
