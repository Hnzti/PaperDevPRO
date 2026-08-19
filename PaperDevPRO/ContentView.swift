import SwiftUI

struct ContentView: View {
    @ObservedObject private var settingsStore = DarkroomSettingsStore.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        DarkroomTimerView()
            .onAppear {
                settingsStore.applyOnAppAppear()
            }
            .onDisappear {
                settingsStore.applyOnAppDisappear()
            }
            .onChange(of: scenePhase) { _, phase in
                switch phase {
                case .active:
                    settingsStore.applyOnAppAppear()
                case .inactive, .background:
                    settingsStore.applyOnAppDisappear()
                @unknown default:
                    break
                }
            }
    }
}

#Preview {
    ContentView()
}
