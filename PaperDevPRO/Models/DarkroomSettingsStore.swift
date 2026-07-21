import Combine
import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

enum AppLanguage: String, CaseIterable, Identifiable {
    case czech = "cs"
    case english = "en"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .czech: return "Čeština"
        case .english: return "English"
        }
    }
}

enum TemperatureUnit: String, CaseIterable, Identifiable {
    case celsius
    case fahrenheit

    var id: String { rawValue }

    func displayName(language: AppLanguage) -> String {
        switch (self, language) {
        case (.celsius, .czech): return "°C"
        case (.celsius, .english): return "°C"
        case (.fahrenheit, .czech): return "°F"
        case (.fahrenheit, .english): return "°F"
        }
    }
}

@MainActor
final class DarkroomSettingsStore: ObservableObject {
    static let shared = DarkroomSettingsStore()

    @Published var isSoundEnabled: Bool {
        didSet { defaults.set(isSoundEnabled, forKey: Keys.sound) }
    }

    @Published var isHapticsEnabled: Bool {
        didSet { defaults.set(isHapticsEnabled, forKey: Keys.haptics) }
    }

    @Published var keepScreenOn: Bool {
        didSet {
            defaults.set(keepScreenOn, forKey: Keys.keepScreenOn)
            applyKeepScreenOn()
        }
    }

    @Published var isDarkroomBrightnessEnabled: Bool {
        didSet {
            defaults.set(isDarkroomBrightnessEnabled, forKey: Keys.brightnessEnabled)
            applyBrightness()
        }
    }

    @Published var darkroomBrightness: Double {
        didSet {
            defaults.set(darkroomBrightness, forKey: Keys.brightness)
            if isDarkroomBrightnessEnabled {
                applyBrightness()
            }
        }
    }

    @Published var defaultTransferSeconds: Int {
        didSet { defaults.set(defaultTransferSeconds, forKey: Keys.transferSeconds) }
    }

    @Published var temperatureUnit: TemperatureUnit {
        didSet { defaults.set(temperatureUnit.rawValue, forKey: Keys.temperatureUnit) }
    }

    @Published var language: AppLanguage {
        didSet { defaults.set(language.rawValue, forKey: Keys.language) }
    }

    var copy: AppCopy { AppCopy(language: language) }

    private let defaults: UserDefaults
    private var storedSystemBrightness: CGFloat?

    private enum Keys {
        static let sound = "settings.soundEnabled"
        static let haptics = "settings.hapticsEnabled"
        static let keepScreenOn = "settings.keepScreenOn"
        static let brightnessEnabled = "settings.darkroomBrightnessEnabled"
        static let brightness = "settings.darkroomBrightness"
        static let transferSeconds = "settings.defaultTransferSeconds"
        static let temperatureUnit = "settings.temperatureUnit"
        static let language = "settings.language"
    }

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        self.isSoundEnabled = defaults.object(forKey: Keys.sound) as? Bool ?? true
        self.isHapticsEnabled = defaults.object(forKey: Keys.haptics) as? Bool ?? true
        self.keepScreenOn = defaults.object(forKey: Keys.keepScreenOn) as? Bool ?? true
        self.isDarkroomBrightnessEnabled = defaults.bool(forKey: Keys.brightnessEnabled)

        let storedBrightness = defaults.object(forKey: Keys.brightness) as? Double
        self.darkroomBrightness = min(max(storedBrightness ?? 0.2, 0.05), 1)

        let storedTransfer = defaults.object(forKey: Keys.transferSeconds) as? Int
        self.defaultTransferSeconds = min(max(storedTransfer ?? 10, 0), 120)

        if let unit = defaults.string(forKey: Keys.temperatureUnit).flatMap(TemperatureUnit.init(rawValue:)) {
            self.temperatureUnit = unit
        } else {
            self.temperatureUnit = .celsius
        }

        if let language = defaults.string(forKey: Keys.language).flatMap(AppLanguage.init(rawValue:)) {
            self.language = language
        } else {
            self.language = .czech
        }
    }

    func applyOnAppAppear() {
        applyKeepScreenOn()
        applyBrightness()
    }

    func applyOnAppDisappear() {
        #if canImport(UIKit)
        UIApplication.shared.isIdleTimerDisabled = false
        #endif
        restoreBrightness()
    }

    func applyKeepScreenOn() {
        #if canImport(UIKit)
        UIApplication.shared.isIdleTimerDisabled = keepScreenOn
        #endif
    }

    func applyBrightness() {
        #if canImport(UIKit)
        if isDarkroomBrightnessEnabled {
            if storedSystemBrightness == nil {
                storedSystemBrightness = UIScreen.main.brightness
            }
            UIScreen.main.brightness = CGFloat(darkroomBrightness)
        } else {
            restoreBrightness()
        }
        #endif
    }

    func restoreBrightness() {
        #if canImport(UIKit)
        if let storedSystemBrightness {
            UIScreen.main.brightness = storedSystemBrightness
            self.storedSystemBrightness = nil
        }
        #endif
    }

    func formatTemperature(_ celsius: Double) -> String {
        switch temperatureUnit {
        case .celsius:
            return String(format: "%.0f °C", celsius)
        case .fahrenheit:
            let fahrenheit = celsius * 9 / 5 + 32
            return String(format: "%.0f °F", fahrenheit)
        }
    }

    func celsius(fromDisplayed value: Double) -> Double {
        switch temperatureUnit {
        case .celsius:
            return value
        case .fahrenheit:
            return (value - 32) * 5 / 9
        }
    }

    func displayedTemperature(fromCelsius celsius: Double) -> Double {
        switch temperatureUnit {
        case .celsius:
            return celsius
        case .fahrenheit:
            return celsius * 9 / 5 + 32
        }
    }
}

struct AppCopy {
    let language: AppLanguage

    var settingsTitle: String { text(cs: "Nastavení", en: "Settings") }
    var redDisplay: String { text(cs: "Červený displej", en: "Red display") }
    var guidedAccess: String { text(cs: "Guidovaný přístup", en: "Guided Access") }
    var openSettings: String { text(cs: "Otevřít", en: "Open") }
    var sound: String { text(cs: "Zvuky", en: "Sounds") }
    var haptics: String { text(cs: "Haptika", en: "Haptics") }
    var keepScreenOn: String { text(cs: "Neusínat", en: "Keep screen on") }
    var darkroomBrightness: String { text(cs: "Nízký jas", en: "Low brightness") }
    var brightnessLevel: String { text(cs: "Úroveň jasu", en: "Brightness level") }
    var defaultTransfer: String { text(cs: "Výchozí přendání", en: "Default transfer") }
    var temperatureUnit: String { text(cs: "Jednotky teploty", en: "Temperature unit") }
    var languageTitle: String { text(cs: "Jazyk", en: "Language") }
    var about: String { text(cs: "O aplikaci", en: "About") }
    var version: String { text(cs: "Verze", en: "Version") }
    var aboutHint: String {
        text(
            cs: "Pro darkroom zapni Barevné filtry a případně Guidovaný přístup ve zpřístupnění iOS.",
            en: "For darkroom use, enable Color Filters and optionally Guided Access in iOS Accessibility."
        )
    }
    var on: String { text(cs: "Zapnuto", en: "On") }
    var off: String { text(cs: "Vypnuto", en: "Off") }
    var secondsSuffix: String { text(cs: "s", en: "s") }

    var start: String { text(cs: "START", en: "START") }
    var pause: String { text(cs: "PAUSE", en: "PAUSE") }
    var resume: String { text(cs: "RESUME", en: "RESUME") }
    var setup: String { text(cs: "SETUP", en: "SETUP") }
    var reset: String { text(cs: "RESET", en: "RESET") }
    var ready: String { text(cs: "READY", en: "READY") }
    var running: String { text(cs: "RUNNING", en: "RUNNING") }
    var paused: String { text(cs: "PAUSED", en: "PAUSED") }
    var complete: String { text(cs: "COMPLETE", en: "COMPLETE") }
    var done: String { text(cs: "DONE", en: "DONE") }
    var paper: String { text(cs: "Papír", en: "Paper") }

    func phaseTitle(_ phase: ProcessPhase) -> String {
        switch (phase, language) {
        case (.developer, .czech): return "Vývojka"
        case (.developer, .english): return "Developer"
        case (.transferToStopBath, .czech), (.transferToFixer, .czech), (.transferToWash, .czech):
            return "Přendání"
        case (.transferToStopBath, .english), (.transferToFixer, .english), (.transferToWash, .english):
            return "Transfer"
        case (.stopBath, .czech): return "Přerušovač"
        case (.stopBath, .english): return "Stop bath"
        case (.fixer, .czech): return "Ustalovač"
        case (.fixer, .english): return "Fixer"
        case (.wash, .czech): return "Praní"
        case (.wash, .english): return "Wash"
        }
    }

    private func text(cs: String, en: String) -> String {
        language == .czech ? cs : en
    }
}

enum SystemSettingsOpener {
    static func openColorFilters() {
        open(candidates: [
            "App-prefs:root=ACCESSIBILITY&path=DISPLAY_AND_TEXT/DISPLAY_FILTER_COLOR",
            "prefs:root=ACCESSIBILITY&path=DISPLAY_AND_TEXT/DISPLAY_FILTER_COLOR",
            "App-prefs:root=ACCESSIBILITY&path=DISPLAY_AND_TEXT#DISPLAY_FILTER_COLOR",
            "prefs:root=ACCESSIBILITY&path=DISPLAY_AND_TEXT#DISPLAY_FILTER_COLOR"
        ])
    }

    static func openGuidedAccess() {
        open(candidates: [
            "App-prefs:root=ACCESSIBILITY&path=GUIDED_ACCESS_TITLE",
            "prefs:root=ACCESSIBILITY&path=GUIDED_ACCESS_TITLE",
            "App-prefs:root=ACCESSIBILITY",
            "prefs:root=ACCESSIBILITY"
        ])
    }

    #if canImport(UIKit)
    private static func open(candidates: [String]) {
        guard let urlString = candidates.first, let url = URL(string: urlString) else { return }

        UIApplication.shared.open(url, options: [:]) { success in
            guard !success else { return }
            open(candidates: Array(candidates.dropFirst()))
        }
    }
    #else
    private static func open(candidates: [String]) {}
    #endif
}
