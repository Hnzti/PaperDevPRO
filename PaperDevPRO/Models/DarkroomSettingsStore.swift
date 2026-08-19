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

    var displayName: String {
        switch self {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        }
    }
}

enum UnitSystem: String, CaseIterable, Identifiable {
    case metric
    case imperial

    var id: String { rawValue }

    func displayName(copy: AppCopy) -> String {
        switch self {
        case .metric: return copy.unitSystemMetric
        case .imperial: return copy.unitSystemImperial
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

    /// When enabled with low brightness, the chosen level stays in iOS after leaving
    /// the app. When disabled, the previous system brightness is restored on exit.
    @Published var keepDarkroomBrightnessAfterExit: Bool {
        didSet {
            defaults.set(keepDarkroomBrightnessAfterExit, forKey: Keys.keepBrightnessAfterExit)
            if keepDarkroomBrightnessAfterExit {
                storedSystemBrightness = nil
            } else if isDarkroomBrightnessEnabled {
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

    @Published var unitSystem: UnitSystem {
        didSet { defaults.set(unitSystem.rawValue, forKey: Keys.unitSystem) }
    }

    @Published var language: AppLanguage {
        didSet {
            defaults.set(language.rawValue, forKey: Keys.language)
        }
    }

    var copy: AppCopy { AppCopy(language: language) }

    private let defaults: UserDefaults

    /// Persisted: when the app is force-quit while dimmed, iOS keeps the dark screen
    /// and the next launch has to know what to restore.
    private var storedSystemBrightness: CGFloat? {
        didSet {
            if let storedSystemBrightness {
                defaults.set(Double(storedSystemBrightness), forKey: Keys.systemBrightness)
            } else {
                defaults.removeObject(forKey: Keys.systemBrightness)
            }
        }
    }

    private enum Keys {
        static let sound = "settings.soundEnabled"
        static let haptics = "settings.hapticsEnabled"
        static let keepScreenOn = "settings.keepScreenOn"
        static let brightnessEnabled = "settings.darkroomBrightnessEnabled"
        static let brightness = "settings.darkroomBrightness"
        static let keepBrightnessAfterExit = "settings.keepDarkroomBrightnessAfterExit"
        static let systemBrightness = "settings.systemBrightnessBackup"
        static let transferSeconds = "settings.defaultTransferSeconds"
        static let temperatureUnit = "settings.temperatureUnit"
        static let unitSystem = "settings.unitSystem"
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
        self.keepDarkroomBrightnessAfterExit = defaults.bool(forKey: Keys.keepBrightnessAfterExit)

        let storedTransfer = defaults.object(forKey: Keys.transferSeconds) as? Int
        self.defaultTransferSeconds = min(max(storedTransfer ?? 10, 0), 120)

        if let unit = defaults.string(forKey: Keys.temperatureUnit).flatMap(TemperatureUnit.init(rawValue:)) {
            self.temperatureUnit = unit
        } else {
            self.temperatureUnit = Locale.current.measurementSystem == .us ? .fahrenheit : .celsius
        }

        if let system = defaults.string(forKey: Keys.unitSystem).flatMap(UnitSystem.init(rawValue:)) {
            self.unitSystem = system
        } else {
            self.unitSystem = Locale.current.measurementSystem == .metric ? .metric : .imperial
        }

        if let language = defaults.string(forKey: Keys.language).flatMap(AppLanguage.init(rawValue:)) {
            self.language = language
        } else {
            self.language = AppLanguage.preferredFromSystem()
        }

        if let backup = defaults.object(forKey: Keys.systemBrightness) as? Double {
            self.storedSystemBrightness = CGFloat(backup)
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
        handleBrightnessOnExit()
    }

    private func handleBrightnessOnExit() {
        #if canImport(UIKit)
        if keepDarkroomBrightnessAfterExit {
            storedSystemBrightness = nil
        } else {
            restoreBrightness()
        }
        #endif
    }

    func applyKeepScreenOn() {
        #if canImport(UIKit)
        UIApplication.shared.isIdleTimerDisabled = keepScreenOn
        #endif
    }

    func applyBrightness() {
        #if canImport(UIKit)
        if isDarkroomBrightnessEnabled {
            if !keepDarkroomBrightnessAfterExit, storedSystemBrightness == nil {
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
        guard !keepDarkroomBrightnessAfterExit else {
            storedSystemBrightness = nil
            return
        }

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

    /// Celsius values for a temperature wheel so that the *displayed* numbers are whole.
    /// In Fahrenheit mode the wheel steps by 1 °F; documented temperatures are always
    /// kept in the list, otherwise the datasheet seal would become unreachable.
    func temperaturePickerValues(
        celsius candidates: [Double],
        documented: [Double] = []
    ) -> [Double] {
        guard temperatureUnit == .fahrenheit,
              let minimum = candidates.min(),
              let maximum = candidates.max() else {
            return candidates
        }

        let lowerFahrenheit = Int(displayedTemperature(fromCelsius: minimum).rounded(.up))
        let upperFahrenheit = Int(displayedTemperature(fromCelsius: maximum).rounded(.down))
        guard lowerFahrenheit <= upperFahrenheit else { return candidates }

        let fromFahrenheit = (lowerFahrenheit...upperFahrenheit)
            .map { celsius(fromDisplayed: Double($0)) }

        let documentedInRange = documented.filter { $0 >= minimum && $0 <= maximum }

        var seen = Set<Int>()
        return (fromFahrenheit + documentedInRange)
            .sorted()
            .filter { seen.insert(Int(($0 * 100).rounded())).inserted }
    }

    func formatLength(centimeters: Double) -> String {
        switch unitSystem {
        case .metric:
            return "\(centimeters.formatted(.number.precision(.fractionLength(0...1)))) cm"
        case .imperial:
            let inches = centimeters / 2.54
            return "\(inches.formatted(.number.precision(.fractionLength(0...1)))) in"
        }
    }

    /// Datasheet value first, and a single conversion only when the user works in the
    /// other unit – so an 8×10 in sheet never shows up as "20.3 x 25.4 cm" alone.
    func formatSize(_ size: PaperSize) -> String {
        guard size.nativeUnit != preferredLengthUnit else {
            return size.displayName
        }

        return "\(size.displayName) (\(size.displayName(in: preferredLengthUnit)))"
    }

    var preferredLengthUnit: LengthUnit {
        switch unitSystem {
        case .metric: return .centimeters
        case .imperial: return .inches
        }
    }

    var lengthUnitLabel: String {
        switch unitSystem {
        case .metric: return copy.centimetersUnit
        case .imperial: return copy.inchesUnit
        }
    }
}
