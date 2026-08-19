import Foundation

enum AppInfo {
    static let displayName = "PaperDev"
    static let contactName = "Jan Kalina"
    static let contactEmail = "galerie.musheri_7e@icloud.com"
    static let supportURL = URL(string: "https://github.com/Hnzti/PaperDevPRO/issues")!
    static let privacyURL = URL(string: "https://github.com/Hnzti/PaperDevPRO/blob/main/docs/privacy.html")!
    /// Same sentence in every language – do not translate.
    static let russianEasterEggMessage = "Русский военный корабль, иди на хуй!"
}

enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case czech = "cs"
    case english = "en"
    case german = "de"
    case french = "fr"
    case spanish = "es"
    case italian = "it"
    case slovenian = "sl"
    case ukrainian = "uk"
    case swedish = "sv"
    case finnish = "fi"
    case norwegian = "nb"
    case danish = "da"
    case slovak = "sk"
    case russian = "ru"
    case greek = "el"
    case japanese = "ja"
    case chinese = "zh"

    var id: String { rawValue }

    /// Czech and Ukrainian see the Snake Island line once, then Russian turns on.
    var showsRussianEasterEgg: Bool {
        self == .czech || self == .ukrainian
    }

    var displayName: String {
        switch self {
        case .czech: return "Čeština"
        case .english: return "English"
        case .german: return "Deutsch"
        case .french: return "Français"
        case .spanish: return "Español"
        case .italian: return "Italiano"
        case .slovenian: return "Slovinština"
        case .ukrainian: return "Українська"
        case .swedish: return "Svenska"
        case .finnish: return "Suomi"
        case .norwegian: return "Norsk bokmål"
        case .danish: return "Dansk"
        case .slovak: return "Slovenština"
        case .russian: return "Русский"
        case .greek: return "Ελληνικά"
        case .japanese: return "日本語"
        case .chinese: return "简体中文"
        }
    }

    /// Language preselected on first launch, derived from the device language list.
    /// Falls back to English when the phone speaks something we do not ship.
    static func preferredFromSystem(
        preferredLanguages: [String] = Locale.preferredLanguages
    ) -> AppLanguage {
        for identifier in preferredLanguages {
            if let language = AppLanguage(systemIdentifier: identifier) {
                return language
            }
        }
        return .english
    }

    private init?(systemIdentifier: String) {
        let code = systemIdentifier
            .split(separator: "-")
            .first
            .map(String.init)?
            .lowercased() ?? systemIdentifier.lowercased()

        switch code {
        // Norwegian ships as Bokmål; Nynorsk speakers read it as well.
        case "no", "nn", "nb": self = .norwegian
        // We ship Simplified Chinese only.
        case "zh": self = .chinese
        default:
            guard let language = AppLanguage(rawValue: code) else { return nil }
            self = language
        }
    }
}

/// CLDR plural categories, limited to the ones our languages actually use.
enum PluralCategory: String {
    case one
    case two
    case few
    case many
    case other

    static func category(for count: Int, language: AppLanguage) -> PluralCategory {
        let n = abs(count)

        switch language {
        case .czech, .slovak:
            if n == 1 { return .one }
            if (2...4).contains(n) { return .few }
            return .other

        case .slovenian:
            switch n % 100 {
            case 1: return .one
            case 2: return .two
            case 3, 4: return .few
            default: return .other
            }

        case .russian, .ukrainian:
            if n % 10 == 1, n % 100 != 11 { return .one }
            if (2...4).contains(n % 10), !(12...14).contains(n % 100) { return .few }
            return .many

        case .french:
            return n <= 1 ? .one : .other

        case .japanese, .chinese:
            return .other

        case .english, .german, .spanish, .italian, .swedish, .finnish,
             .norwegian, .danish, .greek:
            return n == 1 ? .one : .other
        }
    }
}

struct AppCopy {
    let language: AppLanguage

    private func t(_ key: String) -> String {
        Self.table[key]?[language.rawValue]
            ?? Self.table[key]?["en"]
            ?? key
    }

    private func tf(_ key: String, _ args: CVarArg...) -> String {
        String(format: t(key), locale: Locale(identifier: language.rawValue), arguments: args)
    }

    /// Same as `tf`, but without a locale: a year must never get a grouping
    /// separator (`© 2,026`), which is what `%d` does when a locale is supplied.
    private func tfPlain(_ key: String, _ args: CVarArg...) -> String {
        String(format: t(key), arguments: args)
    }

    /// Picks the grammatically correct variant (`key#one`, `key#few`, …) and
    /// falls back to the base key, so a missing variant can never show a raw key.
    private func plural(_ key: String, _ count: Int) -> String {
        let category = PluralCategory.category(for: count, language: language)
        let candidates = ["\(key)#\(category.rawValue)", "\(key)#other", key]
        let format = candidates
            .lazy
            .compactMap { Self.table[$0]?[language.rawValue] ?? Self.table[$0]?["en"] }
            .first ?? key

        return String(format: format, locale: Locale(identifier: language.rawValue), count)
    }

    var a11yDocumented: String { t("a11yDocumented") }
    var a11yInterpolated: String { t("a11yInterpolated") }
    var brightnessLevel: String { t("brightnessLevel") }
    var centimetersUnit: String { t("centimetersUnit") }
    var complete: String { t("complete") }
    var confirmDeleteRunMessage: String { t("confirmDeleteRunMessage") }
    var confirmDeleteRunTitle: String { t("confirmDeleteRunTitle") }
    var confirmNo: String { t("confirmNo") }
    var confirmProjectMessage: String { t("confirmProjectMessage") }
    var confirmSetupMessage: String { t("confirmSetupMessage") }
    var confirmTitle: String { t("confirmTitle") }
    var confirmYes: String { t("confirmYes") }
    var controlsHintAddPaper: String { t("controlsHintAddPaper") }
    var controlsHintAddStrip: String { t("controlsHintAddStrip") }
    var controlsHintDelete: String { t("controlsHintDelete") }
    var customSize: String { t("customSize") }
    var customSizeTitle: String { t("customSizeTitle") }
    var darkroomBrightness: String { t("darkroomBrightness") }
    var keepDarkroomBrightnessAfterExit: String { t("keepDarkroomBrightnessAfterExit") }
    var defaultTransfer: String { t("defaultTransfer") }
    var deletePreset: String { t("deletePreset") }
    var done: String { t("done") }
    var emptyPresetSlot: String { t("emptyPresetSlot") }
    var finishedRunNotice: String { t("finishedRunNotice") }
    var haptics: String { t("haptics") }
    var heightLabel: String { t("heightLabel") }
    var inchesUnit: String { t("inchesUnit") }
    var keepScreenOn: String { t("keepScreenOn") }
    var languageTitle: String { t("languageTitle") }
    var legendDocumented: String { t("legendDocumented") }
    var legendInterpolated: String { t("legendInterpolated") }
    var litersLabel: String { t("litersLabel") }
    var litersUnit: String { t("litersUnit") }
    var longPressAddStripHint: String { t("longPressAddStripHint") }
    var millilitersLabel: String { t("millilitersLabel") }
    var millilitersUnit: String { t("millilitersUnit") }
    var minutesLabel: String { t("minutesLabel") }
    var minutesUnit: String { t("minutesUnit") }
    var noPresetSaved: String { t("noPresetSaved") }
    var notificationRunCompleteBody: String { t("notificationRunCompleteBody") }
    var overwritePreset: String { t("overwritePreset") }
    var paper: String { t("paper") }
    var pause: String { t("pause") }
    var paused: String { t("paused") }
    var pickDeveloper: String { t("pickDeveloper") }
    var pickDeveloperDilution: String { t("pickDeveloperDilution") }
    var pickDeveloperTemperature: String { t("pickDeveloperTemperature") }
    var pickDeveloperVolume: String { t("pickDeveloperVolume") }
    var pickFixer: String { t("pickFixer") }
    var pickFixerDilution: String { t("pickFixerDilution") }
    var pickFixerTemperature: String { t("pickFixerTemperature") }
    var pickFixerVolume: String { t("pickFixerVolume") }
    var pickPaper: String { t("pickPaper") }
    var pickBrand: String { t("pickBrand") }
    var pickProcessDeveloperTime: String { t("pickProcessDeveloperTime") }
    var pickProcessFixerTime: String { t("pickProcessFixerTime") }
    var pickProcessStopBathTime: String { t("pickProcessStopBathTime") }
    var pickProcessTransferToFixerTime: String { t("pickProcessTransferToFixerTime") }
    var pickProcessTransferToStopBathTime: String { t("pickProcessTransferToStopBathTime") }
    var pickProcessTransferToWashTime: String { t("pickProcessTransferToWashTime") }
    var pickProcessTransferToToningTime: String { t("pickProcessTransferToToningTime") }
    var pickProcessWashTime: String { t("pickProcessWashTime") }
    var pickProcessWashAfterToningTime: String { t("pickProcessWashAfterToningTime") }
    var pickSize: String { t("pickSize") }
    var pickStopBath: String { t("pickStopBath") }
    var pickStopBathDilution: String { t("pickStopBathDilution") }
    var pickStopBathTemperature: String { t("pickStopBathTemperature") }
    var pickStopBathVolume: String { t("pickStopBathVolume") }
    var pickToner: String { t("pickToner") }
    var pickTonerDilution: String { t("pickTonerDilution") }
    var pickTonerVolume: String { t("pickTonerVolume") }
    var pickToningBathTemperature: String { t("pickToningBathTemperature") }
    var pickToningTime: String { t("pickToningTime") }
    var pickTransferToFixer: String { t("pickTransferToFixer") }
    var pickTransferToStopBath: String { t("pickTransferToStopBath") }
    var pickTransferToWash: String { t("pickTransferToWash") }
    var pickTransferToToning: String { t("pickTransferToToning") }
    var pickWaterTemperature: String { t("pickWaterTemperature") }
    var presetsTitle: String { t("presetsTitle") }
    var processTransferToFixer: String { t("processTransferToFixer") }
    var processTransferToStopBath: String { t("processTransferToStopBath") }
    var processTransferToWash: String { t("processTransferToWash") }
    var processTransferToToning: String { t("processTransferToToning") }
    var processWashAfterToning: String { t("processWashAfterToning") }
    var ready: String { t("ready") }
    var reset: String { t("reset") }
    var russianEasterEggMessage: String { AppInfo.russianEasterEggMessage }
    var privacyPolicy: String { t("privacyPolicy") }
    var privacyEffectiveDate: String { t("privacyEffectiveDate") }
    var support: String { t("support") }

    var privacySections: [(title: String, body: String)] {
        [
            (t("privacyOverviewTitle"), t("privacyOverviewBody")),
            (t("privacyDataTitle"), t("privacyDataBody")),
            (t("privacyTrackingTitle"), t("privacyTrackingBody")),
            (t("privacyThirdPartiesTitle"), t("privacyThirdPartiesBody")),
            (t("privacyChildrenTitle"), t("privacyChildrenBody")),
            (t("privacyContactTitle"), tf("privacyContactBody", AppInfo.contactEmail)),
        ]
    }

    var supportSections: [(title: String, body: String)] {
        [
            (t("privacyContactTitle"), tf("supportContactBody", AppInfo.contactEmail)),
        ]
    }
    var safelightWarning: String { t("safelightWarning") }
    var resetProject: String { t("resetProject") }
    var resetSetup: String { t("resetSetup") }
    var resume: String { t("resume") }
    var rowCapacity: String { t("rowCapacity") }
    var rowChemicalAmount: String { t("rowChemicalAmount") }
    var rowChemistry: String { t("rowChemistry") }
    var rowDilution: String { t("rowDilution") }
    var rowPaperType: String { t("rowPaperType") }
    var rowPreset: String { t("rowPreset") }
    var rowSize: String { t("rowSize") }
    var rowTemperature: String { t("rowTemperature") }
    var rowTime: String { t("rowTime") }
    var rowTransfer: String { t("rowTransfer") }
    var rowUsed: String { t("rowUsed") }
    var rowVolume: String { t("rowVolume") }
    var rowWashTime: String { t("rowWashTime") }
    var rowWater: String { t("rowWater") }
    var rowWaterTemperature: String { t("rowWaterTemperature") }
    var running: String { t("running") }
    var savePresetButton: String { t("savePresetButton") }
    var savePresetHeader: String { t("savePresetHeader") }
    var secondsLabel: String { t("secondsLabel") }
    var secondsSuffix: String { t("secondsSuffix") }
    var sectionDeveloper: String { t("sectionDeveloper") }
    var sectionFixer: String { t("sectionFixer") }
    var sectionPaper: String { t("sectionPaper") }
    var sectionPresets: String { t("sectionPresets") }
    var sectionProcess: String { t("sectionProcess") }
    var sectionStopBath: String { t("sectionStopBath") }
    var sectionTestStripPaper: String { t("sectionTestStripPaper") }
    var sectionToning: String { t("sectionToning") }
    var sectionWash: String { t("sectionWash") }
    var settingsTitle: String { t("settingsTitle") }
    var setup: String { t("setup") }
    var setupTitle: String { t("setupTitle") }
    var sound: String { t("sound") }
    var start: String { t("start") }
    var sync: String { t("sync") }
    var temperatureLabel: String { t("temperatureLabel") }
    var temperatureUnit: String { t("temperatureUnit") }
    var testStrip: String { t("testStrip") }
    var timeVisual: String { t("timeVisual") }
    var toningManualContinue: String { t("toningManualContinue") }
    var unitSystem: String { t("unitSystem") }
    var unitSystemImperial: String { t("unitSystemImperial") }
    var unitSystemMetric: String { t("unitSystemMetric") }
    var version: String { t("version") }
    var widthLabel: String { t("widthLabel") }

    var copyright: String { tfPlain("copyright", Self.copyrightYear) }

    var controlsHint: String {
        [controlsHintAddPaper, controlsHintAddStrip, controlsHintDelete].joined(separator: "\n")
    }

    func presetsSavedCount(_ count: Int) -> String { plural("presetsSavedCount", count) }
    func confirmOverwritePresetMessage(_ name: String) -> String { tf("confirmOverwritePresetMessage", name) }
    func confirmDeletePresetMessage(_ name: String) -> String { tf("confirmDeletePresetMessage", name) }
    func presetSlotName(_ letter: String) -> String { tf("presetSlotName", letter) }

    func paperTypeName(_ type: PaperType) -> String {
        switch type {
        case .resinCoated: return t("paperTypeResinCoated")
        case .fiberBased: return t("paperTypeFiberBased")
        }
    }

    func phaseTitle(_ phase: ProcessPhase) -> String {
        switch phase {
        case .developer: return t("phaseDeveloper")
        case .transferToStopBath, .transferToFixer, .transferToWash, .transferToToning, .transferToWashAfterToning:
            return t("phaseTransfer")
        case .stopBath: return t("phaseStopBath")
        case .fixer: return t("phaseFixer")
        case .wash, .washAfterToning: return t("phaseWash")
        case .toning: return t("phaseToning")
        }
    }

    private static let copyrightYear = Calendar(identifier: .gregorian)
        .component(.year, from: Date())

    private static let table: [String: [String: String]] = {
        guard let url = Bundle.main.url(forResource: "Localizations", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: [String: String]].self, from: data) else {
            assertionFailure("Missing Localizations.json")
            return [:]
        }
        return decoded
    }()

}
