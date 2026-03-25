# Meme Physics - iOS Cat Meme Game

A physics-based cat meme interaction game built with SwiftUI and SpriteKit.

## Features

- **Physics-Based Cat Interactions**: Tap, drag, swipe, and throw the cat with realistic physics
- **7 Unique Cat Memes**: Pop Cat, Bongo Cat, Huh Cat, Angry Cat, Crying Cat, Wide Cat, Silly Cat
- **Dynamic Galaxy Background**: Animated stars, triangle mesh, and nebula glow
- **Meme Rain**: Mini cats fall from the sky periodically
- **Haptic Feedback**: Character-specific haptic profiles (pop, rhythmic, confused, aggressive, soft, wobbly, playful)
- **Unlock System**: Earn points to unlock new cats
- **Persistent Progress**: Save data using UserDefaults

## Project Structure

```
CatMemePhysicsGame/
├── App/
│   └── CatMemePhysicsGameApp.swift
├── Models/
│   ├── CatMeme.swift
│   ├── HapticProfile.swift
│   ├── PhysicsProfile.swift
│   └── GameSettings.swift
├── ViewModels/
│   └── GameViewModel.swift
├── Views/
│   ├── HomeView.swift
│   ├── GameView.swift
│   ├── CollectionView.swift
│   ├── SettingsView.swift
│   └── Components/
│       ├── MemeCardView.swift
│       ├── BlurGlowBackground.swift
│       ├── GalaxyBackgroundView.swift
│       └── SpriteSceneContainer.swift
├── Scenes/
│   └── CatPhysicsScene.swift
├── Managers/
│   ├── AudioManager.swift
│   ├── HapticManager.swift
│   └── PersistenceManager.swift
└── Helpers/
    ├── Constants.swift
    └── ColorPalette.swift
```

## Cat Memes

| Cat | Unlock Cost | Physics | Haptic |
|-----|-------------|---------|--------|
| Pop Cat | Free | Bouncy | Pop |
| Bongo Cat | 150 | Balanced | Rhythmic |
| Huh Cat | 300 | Stiff | Confused |
| Angry Cat | 500 | Heavy | Aggressive |
| Crying Cat | 750 | Floaty | Soft |
| Wide Cat | 1200 | Wide | Wobbly |
| Silly Cat | 2000 | Chaotic | Playful |

## Requirements

- iOS 17.0+
- Xcode 15+
- Swift 5.9+

## Setup

1. Create new Xcode project (iOS App, SwiftUI)
2. Copy all Swift files to appropriate folders
3. Add image assets to Assets.xcassets
4. Add audio files to project
5. Build and run
