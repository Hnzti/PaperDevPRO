import Foundation

#if canImport(UIKit)
import UIKit
#endif

enum SystemSettingsOpener {
    static func openColorFilters() {
        #if canImport(UIKit)
        let candidates = [
            "App-prefs:root=ACCESSIBILITY&path=DISPLAY_AND_TEXT/COLOR_FILTERS",
            "App-Prefs:root=ACCESSIBILITY&path=DISPLAY_AND_TEXT/COLOR_FILTERS",
            "prefs:root=ACCESSIBILITY&path=DISPLAY_AND_TEXT/COLOR_FILTERS",
            "App-prefs:root=ACCESSIBILITY&path=DISPLAY_AND_TEXT",
            "prefs:root=ACCESSIBILITY&path=DISPLAY_AND_TEXT"
        ]

        openFirstAvailable(candidates) {
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }
        #endif
    }

    #if canImport(UIKit)
    private static func openFirstAvailable(_ candidates: [String], fallback: @escaping () -> Void) {
        guard let urlString = candidates.first, let url = URL(string: urlString) else {
            fallback()
            return
        }

        UIApplication.shared.open(url, options: [:]) { success in
            if success {
                return
            }

            openFirstAvailable(Array(candidates.dropFirst()), fallback: fallback)
        }
    }
    #endif
}
