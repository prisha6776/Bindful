import SwiftUI

@main
struct EcoLensApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ScanStore.shared)
                .preferredColorScheme(.light)
        }
    }
}
