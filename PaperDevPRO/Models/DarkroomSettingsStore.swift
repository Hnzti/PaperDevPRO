import Combine
import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

enum TemperatureUnit: String, CaseIterable, Identifiable {
    case celsius
    case fahrenheit

    var id: String { rawValue }

    func displayName(language: AppLanguage) -> String {
        switch self {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
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
        didSet {
            if language.isTemporarilyBlocked {
                language = oldValue.isTemporarilyBlocked ? .czech : oldValue
                return
            }
            defaults.set(language.rawValue, forKey: Keys.language)
        }
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

        if let language = defaults.string(forKey: Keys.language).flatMap(AppLanguage.init(rawValue:)),
           !language.isTemporarilyBlocked {
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
