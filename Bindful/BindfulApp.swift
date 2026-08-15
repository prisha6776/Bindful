import SwiftUI

@main
struct BindfulApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ScanStore.shared)
                .preferredColorScheme(.light)
        }
    }
}
