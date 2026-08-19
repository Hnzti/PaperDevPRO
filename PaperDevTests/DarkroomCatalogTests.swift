import XCTest
@testable import PaperDev

/// Guards the shipped datasheet data. `DarkroomCatalog.defaultSession` traps on an
/// incomplete catalog, so these invariants are what makes that precondition safe.
final class DarkroomCatalogTests: XCTestCase {
    func testCatalogHasEveryRoleAndAtLeastOnePaper() {
        XCTAssertFalse(DarkroomCatalog.papers.isEmpty)
        XCTAssertFalse(DarkroomCatalog.developers.isEmpty)
        XCTAssertFalse(DarkroomCatalog.stopBaths.isEmpty)
        XCTAssertFalse(DarkroomCatalog.fixers.isEmpty)
    }

    func testPaperIdentifiersAreUnique() {
        let identifiers = DarkroomCatalog.papers.map(\.id)
        XCTAssertEqual(identifiers.count, Set(identifiers).count)
    }

    func testChemicalIdentifiersAreUnique() {
        let identifiers = DarkroomCatalog.chemicals.map(\.id)
        XCTAssertEqual(identifiers.count, Set(identifiers).count)
    }

    func testEveryPaperHasSizesAndWashRules() {
        for paper in DarkroomCatalog.papers {
            XCTAssertFalse(paper.availableSizes.isEmpty, paper.id)
            XCTAssertFalse(paper.washRules.isEmpty, paper.id)

            for size in paper.availableSizes {
                XCTAssertGreaterThan(size.widthCentimeters, 0, paper.id)
                XCTAssertGreaterThan(size.heightCentimeters, 0, paper.id)
            }
        }
    }

    func testEveryChemicalHasAtLeastOneDilution() {
        for chemical in DarkroomCatalog.chemicals {
            XCTAssertFalse(chemical.dilutions.isEmpty, chemical.id)
        }
    }

    func testRulesOnlyReferenceKnownPapers() {
        let knownPapers = Set(DarkroomCatalog.papers.map(\.id))

        for chemical in DarkroomCatalog.chemicals {
            for dilution in chemical.dilutions {
                for rule in dilution.timeRules {
                    if let paperID = rule.paperID {
                        XCTAssertTrue(knownPapers.contains(paperID), "\(chemical.id): \(paperID)")
                    }
                    XCTAssertGreaterThan(rule.timeRange.minimum, 0, chemical.id)
                    XCTAssertLessThanOrEqual(rule.timeRange.minimum, rule.timeRange.maximum, chemical.id)
                }

                for rule in dilution.capacityRules {
                    if let paperID = rule.paperID {
                        XCTAssertTrue(knownPapers.contains(paperID), "\(chemical.id): \(paperID)")
                    }
                    XCTAssertGreaterThan(rule.squareMetersPerLiter, 0, chemical.id)
                }
            }
        }
    }

    func testDefaultSessionUsesFirstPaperAndFirstSize() {
        let session = DarkroomCatalog.defaultSession
        XCTAssertEqual(session.paper.id, DarkroomCatalog.papers.first?.id)
        XCTAssertEqual(session.paperSize.id, DarkroomCatalog.papers.first?.availableSizes.first?.id)
        XCTAssertFalse(session.resolvedPhases().isEmpty)
    }

    func testRefreshedSessionRebindsToCatalogButKeepsUserChoices() throws {
        var stored = DarkroomCatalog.defaultSession
        let customSize = PaperSize(widthCentimeters: 2.5, heightCentimeters: 10)
        stored.paperSize = customSize
        stored.developerTemperatureCelsius = 24
        stored.developerVolumeMilliliters = 1_500
        stored.phaseDurationOverrides = [.developer: 111]

        // Simulate a preset saved before a datasheet correction.
        let staleDeveloper = Chemical(
            id: stored.developer.id,
            manufacturer: stored.developer.manufacturer,
            name: "OUTDATED",
            role: .developer,
            dilutions: [ChemicalDilution(ratio: stored.developerDilution.ratio)]
        )
        stored.developer = staleDeveloper

        let refreshed = DarkroomCatalog.refreshed(stored)

        XCTAssertEqual(refreshed.developer.name, DarkroomCatalog.chemical(id: staleDeveloper.id)?.name)
        XCTAssertEqual(refreshed.developerDilution.ratio, stored.developerDilution.ratio)
        XCTAssertEqual(refreshed.paperSize.id, customSize.id)
        XCTAssertEqual(refreshed.developerTemperatureCelsius, 24)
        XCTAssertEqual(refreshed.developerVolumeMilliliters, 1_500)
        XCTAssertEqual(refreshed.phaseDurationOverrides[.developer], 111)
    }

    /// Datasheet: MULTIGRADE RC Cooltone doubles the development time, and the same
    /// sheet halves the capacity for it.
    func testCooltoneUsesDoubledTimeAndHalvedCapacity() throws {
        let developer = try XCTUnwrap(DarkroomCatalog.chemical(id: "ilford-multigrade"))
        let dilution = try XCTUnwrap(developer.dilutions.first { $0.ratio == "1+9" })
        let cooltone = try XCTUnwrap(DarkroomCatalog.paper(id: "ilford-multigrade-rc-cooltone"))
        let deluxe = try XCTUnwrap(DarkroomCatalog.paper(id: "ilford-multigrade-rc-deluxe"))

        let cooltoneTime = dilution.timeRange(
            for: cooltone,
            temperatureCelsius: 20,
            chemicalManufacturer: developer.manufacturer
        )
        let deluxeTime = dilution.timeRange(
            for: deluxe,
            temperatureCelsius: 20,
            chemicalManufacturer: developer.manufacturer
        )

        XCTAssertEqual(cooltoneTime.recommended, deluxeTime.recommended * 2)
        XCTAssertTrue(
            dilution.isDocumented(
                for: cooltone,
                temperatureCelsius: 20,
                chemicalManufacturer: developer.manufacturer
            )
        )

        let cooltoneUsage = ChemicalUsageEntry(
            paperType: .resinCoated,
            areaSquareMeters: 1,
            paperID: cooltone.id
        )
        let deluxeUsage = ChemicalUsageEntry(
            paperType: .resinCoated,
            areaSquareMeters: 1,
            paperID: deluxe.id
        )

        let cooltoneRemaining = dilution.capacityPercent(usages: [cooltoneUsage], workingSolutionLiters: 1)
        let deluxeRemaining = dilution.capacityPercent(usages: [deluxeUsage], workingSolutionLiters: 1)

        XCTAssertNotNil(cooltoneRemaining)
        XCTAssertNotNil(deluxeRemaining)
        XCTAssertLessThan(try XCTUnwrap(cooltoneRemaining), try XCTUnwrap(deluxeRemaining))
    }

    /// Fomafix 1+4 copies the manual times, so it must never claim the datasheet seal
    /// even though it is still offered and still returns a usable time.
    func testEstimatedRuleIsUsableButNotDocumented() throws {
        let fixer = try XCTUnwrap(DarkroomCatalog.chemical(id: "foma-fomafix"))
        let dilution = try XCTUnwrap(fixer.dilutions.first { $0.ratio == "1+4" })
        let paper = try XCTUnwrap(DarkroomCatalog.paper(id: "foma-fomabrom"))

        XCTAssertTrue(dilution.isApplicable(for: paper, chemicalManufacturer: fixer.manufacturer))
        XCTAssertFalse(dilution.isDocumented(for: paper, chemicalManufacturer: fixer.manufacturer))
        XCTAssertEqual(
            dilution.timeRange(
                for: paper,
                temperatureCelsius: 20,
                chemicalManufacturer: fixer.manufacturer
            ).recommended,
            180
        )
        XCTAssertTrue(fixer.isApplicable(for: paper))
    }

    /// HARMAN Selenium TDS: 1+3 is visual toning (25× 8×10" / L), 1+20 is 2–4 min
    /// archival protection. The toner is for all RC and FB papers.
    func testHarmanSeleniumMatchesDatasheet() throws {
        let toner = try XCTUnwrap(DarkroomCatalog.chemical(id: "ilford-harman-selenium"))
        XCTAssertEqual(toner.role, .toner)
        XCTAssertEqual(toner.dilutions.map(\.ratio), ["1+3", "1+20"])

        let normal = try XCTUnwrap(toner.dilutions.first { $0.ratio == "1+3" })
        XCTAssertTrue(normal.timeRules.isEmpty)
        XCTAssertEqual(normal.capacityRules.map(\.squareMetersPerLiter), [1.3, 1.3])

        let archival = try XCTUnwrap(toner.dilutions.first { $0.ratio == "1+20" })
        let ilfordPaper = try XCTUnwrap(DarkroomCatalog.paper(id: "ilford-multigrade-rc-deluxe"))
        let fomaPaper = try XCTUnwrap(DarkroomCatalog.paper(id: "foma-fomabrom-variant"))
        XCTAssertEqual(
            archival.timeRange(
                for: ilfordPaper,
                temperatureCelsius: 20,
                chemicalManufacturer: toner.manufacturer
            ),
            TimeRange(minimum: 120, maximum: 240)
        )
        XCTAssertEqual(
            archival.postToningWashDuration(for: ilfordPaper, waterTemperatureCelsius: 20),
            2 * 60
        )
        XCTAssertEqual(
            archival.postToningWashDuration(for: fomaPaper, waterTemperatureCelsius: 20),
            30 * 60
        )
        XCTAssertTrue(toner.isApplicable(for: ilfordPaper))
        XCTAssertTrue(toner.isApplicable(for: fomaPaper))
    }

    func testFomatonerSepiaUsesDatasheetBleachTime() throws {
        let toner = try XCTUnwrap(DarkroomCatalog.chemical(id: "foma-fomatoner-sepia"))
        let paper = try XCTUnwrap(DarkroomCatalog.paper(id: "foma-fomabrom-variant"))
        let dilution = try XCTUnwrap(toner.dilutions.first)

        XCTAssertEqual(
            dilution.timeRange(
                for: paper,
                temperatureCelsius: 25,
                chemicalManufacturer: toner.manufacturer
            ),
            TimeRange(minimum: 120, maximum: 180)
        )
        XCTAssertTrue(
            dilution.isDocumented(
                for: paper,
                temperatureCelsius: 25,
                chemicalManufacturer: toner.manufacturer
            )
        )
        XCTAssertNil(dilution.postToningWashDuration(for: paper, waterTemperatureCelsius: 20))
    }
}
