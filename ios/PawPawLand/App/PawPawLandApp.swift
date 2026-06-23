import SwiftUI

@main
struct PawPawLandApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(appState)
        }
    }
}
