import XCTest
@testable import PaperDev

final class LocalizationTests: XCTestCase {
    private var table: [String: [String: String]] = [:]

    override func setUpWithError() throws {
        let url = try XCTUnwrap(
            Bundle.main.url(forResource: "Localizations", withExtension: "json"),
            "Localizations.json is not in the app bundle"
        )
        table = try JSONDecoder().decode(
            [String: [String: String]].self,
            from: try Data(contentsOf: url)
        )
    }

    func testEveryKeyIsTranslatedIntoEveryShippedLanguage() {
        for language in AppLanguage.allCases {
            let missing = table
                .filter { ($0.value[language.rawValue] ?? "").isEmpty }
                .keys
                .sorted()

            XCTAssertTrue(missing.isEmpty, "\(language.rawValue) is missing: \(missing)")
        }
    }

    func testFormatSpecifiersMatchEnglish() {
        for (key, translations) in table {
            let englishSpecifiers = Self.specifiers(in: translations["en"] ?? "")

            for language in AppLanguage.allCases {
                let specifiers = Self.specifiers(in: translations[language.rawValue] ?? "")
                XCTAssertEqual(
                    specifiers,
                    englishSpecifiers,
                    "\(key) / \(language.rawValue) has different placeholders than English"
                )
            }
        }
    }

    func testNoUserFacingStringStillReadsAsRawEnglishStatus() {
        // These used to sit in the Czech column verbatim.
        let keys = ["ready", "running", "paused", "complete", "done"]

        for key in keys {
            let czech = table[key]?["cs"] ?? ""
            let english = table[key]?["en"] ?? ""
            XCTAssertNotEqual(czech, english, key)
        }
    }

    func testPluralVariantsExistForSlavicLanguages() {
        // The base key carries the `other` form, the variants the rest.
        XCTAssertNotNil(table["presetsSavedCount"])
        for category in ["one", "two", "few", "many"] {
            XCTAssertNotNil(table["presetsSavedCount#\(category)"], category)
        }

        let czech = AppCopy(language: .czech)
        XCTAssertEqual(czech.presetsSavedCount(1), "1 uložená")
        XCTAssertEqual(czech.presetsSavedCount(3), "3 uložené")
        XCTAssertEqual(czech.presetsSavedCount(8), "8 uložených")
    }

    func testPluralCategories() {
        XCTAssertEqual(PluralCategory.category(for: 1, language: .czech), .one)
        XCTAssertEqual(PluralCategory.category(for: 4, language: .czech), .few)
        XCTAssertEqual(PluralCategory.category(for: 5, language: .czech), .other)

        XCTAssertEqual(PluralCategory.category(for: 21, language: .russian), .one)
        XCTAssertEqual(PluralCategory.category(for: 11, language: .russian), .many)
        XCTAssertEqual(PluralCategory.category(for: 3, language: .ukrainian), .few)

        XCTAssertEqual(PluralCategory.category(for: 2, language: .slovenian), .two)
        XCTAssertEqual(PluralCategory.category(for: 7, language: .japanese), .other)
    }

    func testCopyrightYearIsNotHardcoded() {
        let year = Calendar(identifier: .gregorian).component(.year, from: Date())
        XCTAssertTrue(AppCopy(language: .english).copyright.contains("\(year)"))
    }

    func testPaperTypeNamesAreLocalized() {
        XCTAssertNotEqual(
            AppCopy(language: .czech).paperTypeName(.fiberBased),
            AppCopy(language: .english).paperTypeName(.fiberBased)
        )
    }

    func testSystemLanguageFallsBackToEnglishAndSkipsBlockedLanguages() {
        XCTAssertEqual(AppLanguage.preferredFromSystem(preferredLanguages: ["cs-CZ"]), .czech)
        XCTAssertEqual(AppLanguage.preferredFromSystem(preferredLanguages: ["zh-Hans-CN"]), .chinese)
        XCTAssertEqual(AppLanguage.preferredFromSystem(preferredLanguages: ["nn-NO"]), .norwegian)
        XCTAssertEqual(AppLanguage.preferredFromSystem(preferredLanguages: ["hu-HU"]), .english)
        XCTAssertEqual(
            AppLanguage.preferredFromSystem(preferredLanguages: ["ru-RU", "sk-SK"]),
            AppLanguage.isRussianTemporarilyBlocked ? .slovak : .russian
        )
    }

    func testResetWordIsResetInEveryLanguage() {
        for language in AppLanguage.allCases {
            XCTAssertEqual(table["reset"]?[language.rawValue], "RESET")
        }
    }

    func testTimerControlButtonsStayEnglishInEveryLanguage() {
        let expected = [
            "start": "START",
            "pause": "PAUSE",
            "resume": "RESUME",
            "setup": "SETUP",
        ]
        for (key, value) in expected {
            for language in AppLanguage.allCases {
                XCTAssertEqual(table[key]?[language.rawValue], value, "\(key) / \(language.rawValue)")
            }
        }
    }

    func testSlovakAndSlovenianNamesAreDistinctCzechNames() {
        XCTAssertEqual(AppLanguage.slovak.displayName, "Slovenština")
        XCTAssertEqual(AppLanguage.slovenian.displayName, "Slovinština")
        XCTAssertNotEqual(AppLanguage.slovak.displayName, AppLanguage.slovenian.displayName)
    }

    func testRussianBlockedMessageIsUntranslated() {
        XCTAssertEqual(
            AppCopy(language: .czech).russianLanguageBlockedMessage,
            AppInfo.russianBlockedMessage
        )
        XCTAssertEqual(
            AppCopy(language: .english).russianLanguageBlockedMessage,
            AppInfo.russianBlockedMessage
        )
        XCTAssertEqual(
            AppCopy(language: .ukrainian).russianLanguageBlockedMessage,
            AppInfo.russianBlockedMessage
        )
    }

    private static func specifiers(in value: String) -> [String] {
        var result: [String] = []
        let characters = Array(value)
        var index = 0

        while index < characters.count - 1 {
            if characters[index] == "%" {
                let next = characters[index + 1]
                if next == "%" {
                    index += 2
                    continue
                }
                result.append("%\(next)")
            }
            index += 1
        }

        return result
    }
}
