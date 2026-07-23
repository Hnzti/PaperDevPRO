import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

@main
struct PaperDevPROApp: App {
    init() {
        #if canImport(UIKit)
        // Systémová klávesnice nejde přebarvit na červenou – aspoň dark appearance,
        // ať nesvítí bílá.
        UITextField.appearance().keyboardAppearance = .dark
        UITextView.appearance().keyboardAppearance = .dark
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
 
