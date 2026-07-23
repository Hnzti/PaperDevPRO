import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
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

    /// Flip to `false` after the war to re-enable Russian.
    static var isRussianTemporarilyBlocked = true

    var isTemporarilyBlocked: Bool {
        self == .russian && Self.isRussianTemporarilyBlocked
    }

    var displayName: String {
        switch self {
        case .czech: return "Čeština"
        case .english: return "English"
        case .german: return "Deutsch"
        case .french: return "Français"
        case .spanish: return "Español"
        case .italian: return "Italiano"
        case .slovenian: return "Slovenščina"
        case .ukrainian: return "Українська"
        case .swedish: return "Svenska"
        case .finnish: return "Suomi"
        case .norwegian: return "Norsk"
        case .danish: return "Dansk"
        case .slovak: return "Slovenčina"
        case .russian: return "Русский"
        case .greek: return "Ελληνικά"
        case .japanese: return "日本語"
        case .chinese: return "中文"
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

    var a11yDocumented: String { t("a11yDocumented") }
    var a11yInterpolated: String { t("a11yInterpolated") }
    var about: String { t("about") }
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
    var copyright: String { t("copyright") }
    var customSize: String { t("customSize") }
    var customSizeTitle: String { t("customSizeTitle") }
    var darkroomBrightness: String { t("darkroomBrightness") }
    var defaultTransfer: String { t("defaultTransfer") }
    var deletePreset: String { t("deletePreset") }
    var done: String { t("done") }
    var emptyPresetSlot: String { t("emptyPresetSlot") }
    var haptics: String { t("haptics") }
    var heightLabel: String { t("heightLabel") }
    var keepScreenOn: String { t("keepScreenOn") }
    var languageTitle: String { t("languageTitle") }
    var legendDocumented: String { t("legendDocumented") }
    var legendInterpolated: String { t("legendInterpolated") }
    var litersLabel: String { t("litersLabel") }
    var litersUnit: String { t("litersUnit") }
    var loadPreset: String { t("loadPreset") }
    var longPressAddStripHint: String { t("longPressAddStripHint") }
    var millilitersLabel: String { t("millilitersLabel") }
    var millilitersUnit: String { t("millilitersUnit") }
    var minutesLabel: String { t("minutesLabel") }
    var minutesUnit: String { t("minutesUnit") }
    var noPresetSaved: String { t("noPresetSaved") }
    var off: String { t("off") }
    var on: String { t("on") }
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
    var pickProcessDeveloperTime: String { t("pickProcessDeveloperTime") }
    var pickProcessFixerTime: String { t("pickProcessFixerTime") }
    var pickProcessStopBathTime: String { t("pickProcessStopBathTime") }
    var pickProcessTransferToFixerTime: String { t("pickProcessTransferToFixerTime") }
    var pickProcessTransferToStopBathTime: String { t("pickProcessTransferToStopBathTime") }
    var pickProcessTransferToWashTime: String { t("pickProcessTransferToWashTime") }
    var pickProcessWashTime: String { t("pickProcessWashTime") }
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
    var pickWaterTemperature: String { t("pickWaterTemperature") }
    var presetsTitle: String { t("presetsTitle") }
    var processTransferToFixer: String { t("processTransferToFixer") }
    var processTransferToStopBath: String { t("processTransferToStopBath") }
    var processTransferToWash: String { t("processTransferToWash") }
    var ready: String { t("ready") }
    var reset: String { t("reset") }
    var russianLanguageBlockedMessage: String { t("russianLanguageBlockedMessage") }
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
    var toner: String { t("toner") }
    var version: String { t("version") }
    var volumeLabel: String { t("volumeLabel") }
    var widthLabel: String { t("widthLabel") }

    var controlsHint: String {
        [controlsHintAddPaper, controlsHintAddStrip, controlsHintDelete].joined(separator: "\n")
    }

    func presetsSavedCount(_ count: Int) -> String { tf("presetsSavedCount", count) }
    func confirmOverwritePresetMessage(_ name: String) -> String { tf("confirmOverwritePresetMessage", name) }
    func confirmDeletePresetMessage(_ name: String) -> String { tf("confirmDeletePresetMessage", name) }

    func phaseTitle(_ phase: ProcessPhase) -> String {
        switch phase {
        case .developer: return t("phaseDeveloper")
        case .transferToStopBath, .transferToFixer, .transferToWash: return t("phaseTransfer")
        case .stopBath: return t("phaseStopBath")
        case .fixer: return t("phaseFixer")
        case .wash: return t("phaseWash")
        case .toning: return t("phaseToning")
        }
    }

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
