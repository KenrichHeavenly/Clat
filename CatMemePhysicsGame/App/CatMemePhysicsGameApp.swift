import SwiftUI

@main
struct CatMemePhysicsGameApp: App {
    @StateObject private var viewModel = GameViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .preferredColorScheme(.dark)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            GalaxyBackgroundView()
                .ignoresSafeArea()
            
            switch viewModel.currentScreen {
            case .home:
                HomeView()
                    .transition(.opacity)
            case .game:
                GameView()
                    .transition(.opacity)
            case .collection:
                CollectionView()
                    .transition(.opacity)
            case .settings:
                SettingsView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentScreen)
    }
}

enum AppScreen {
    case home, game, collection, settings
}
