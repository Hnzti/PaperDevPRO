import XCTest
@testable import PaperDev

final class DarkroomModelTests: XCTestCase {
    func testPaperSizeIdentityIgnoresFloatingPointNoise() {
        let fromCatalog = PaperSize(widthCentimeters: 7.62, heightCentimeters: 25.4)
        let fromInches = PaperSize(widthCentimeters: 3 * 2.54, heightCentimeters: 10 * 2.54)

        XCTAssertEqual(fromCatalog.id, fromInches.id)
        XCTAssertNotEqual(
            fromCatalog.id,
            PaperSize(widthCentimeters: 7.63, heightCentimeters: 25.4).id
        )
    }

    func testWashDurationFallsBackToLongestRuleBelowTheColdestRule() {
        let paper = Paper(
            id: "test",
            manufacturer: "Test",
            name: "Test",
            type: .fiberBased,
            availableSizes: [PaperSize(widthCentimeters: 10, heightCentimeters: 15)],
            washRules: [
                WashRule(minimumTemperatureCelsius: 5, duration: 600),
                WashRule(minimumTemperatureCelsius: 20, duration: 300)
            ],
            developerTemperatureCurve: []
        )

        XCTAssertEqual(paper.washDuration(for: 20), 600)
        // 2 °C is below every rule – must not report "no wash needed".
        XCTAssertEqual(paper.washDuration(for: 2), 600)
    }

    func testTimeRangeInterpolatesBetweenTemperatures() {
        let interpolated = TimeRange.interpolate(
            from: TimeRange(seconds: 100),
            at: 20,
            to: TimeRange(seconds: 50),
            at: 30,
            targetTemperature: 25
        )

        XCTAssertEqual(interpolated.recommended, 75)
    }

    func testMixComponentsSplitsByRatio() {
        XCTAssertEqual(
            ChemicalDilution(ratio: "1+9").mixComponents(totalMilliliters: 1_000),
            DilutionMix(chemicalMilliliters: 100, waterMilliliters: 900)
        )
        XCTAssertEqual(
            ChemicalDilution(ratio: "stock").mixComponents(totalMilliliters: 500),
            DilutionMix(chemicalMilliliters: 500, waterMilliliters: 0)
        )
        // Spacing must not change the mix.
        XCTAssertEqual(
            ChemicalDilution(ratio: "1 + 4").mixComponents(totalMilliliters: 1_000),
            DilutionMix(chemicalMilliliters: 200, waterMilliliters: 800)
        )
    }

    func testCapacityScalesWithSolutionVolume() {
        let dilution = ChemicalDilution(
            ratio: "1+9",
            capacityRules: [
                ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 1)
            ]
        )
        let usage = [ChemicalUsageEntry(paperType: .resinCoated, areaSquareMeters: 1)]

        // 1 m² processed: exhausted in 1 l, half exhausted in 2 l – that is the
        // "topping up revives the bath" rule expressed in percent.
        XCTAssertEqual(dilution.capacityPercent(usages: usage, workingSolutionLiters: 1), 0)
        XCTAssertEqual(dilution.capacityPercent(usages: usage, workingSolutionLiters: 2), 50)
        XCTAssertEqual(dilution.capacityPercent(usages: usage, workingSolutionLiters: 4), 75)
        XCTAssertNil(dilution.capacityPercent(usages: usage, workingSolutionLiters: 0))
    }

    func testRuleSelectionPrefersPaperIdentifierThenType() throws {
        let paper = try XCTUnwrap(DarkroomCatalog.paper(id: "foma-fomabrom-variant"))
        let developer = try XCTUnwrap(DarkroomCatalog.chemical(id: "foma-fomatol-lqn"))
        let dilution = try XCTUnwrap(developer.dilutions.first)

        // 25 °C is documented for this paper, 27 °C has to be interpolated.
        XCTAssertTrue(
            dilution.isDocumented(
                for: paper,
                temperatureCelsius: 25,
                chemicalManufacturer: developer.manufacturer
            )
        )
        XCTAssertFalse(
            dilution.isDocumented(
                for: paper,
                temperatureCelsius: 27,
                chemicalManufacturer: developer.manufacturer
            )
        )

        let interpolated = dilution.timeRange(
            for: paper,
            temperatureCelsius: 27,
            chemicalManufacturer: developer.manufacturer
        )
        let colder = dilution.timeRange(
            for: paper,
            temperatureCelsius: 25,
            chemicalManufacturer: developer.manufacturer
        )
        let warmer = dilution.timeRange(
            for: paper,
            temperatureCelsius: 30,
            chemicalManufacturer: developer.manufacturer
        )

        XCTAssertLessThan(interpolated.recommended, colder.recommended)
        XCTAssertGreaterThan(interpolated.recommended, warmer.recommended)
    }

    func testCrossBrandCombinationStaysUndocumentedButDeterministic() throws {
        let fomaPaper = try XCTUnwrap(DarkroomCatalog.paper(id: "foma-fomabrom"))
        let ilfordDeveloper = try XCTUnwrap(DarkroomCatalog.chemical(id: "ilford-multigrade"))
        let dilution = try XCTUnwrap(ilfordDeveloper.dilutions.first)

        XCTAssertFalse(dilution.isApplicable(
            for: fomaPaper,
            chemicalManufacturer: ilfordDeveloper.manufacturer
        ))

        let first = dilution.timeRange(
            for: fomaPaper,
            temperatureCelsius: 20,
            chemicalManufacturer: ilfordDeveloper.manufacturer
        )
        let second = dilution.timeRange(
            for: fomaPaper,
            temperatureCelsius: 20,
            chemicalManufacturer: ilfordDeveloper.manufacturer
        )

        XCTAssertEqual(first, second)
    }

    func testEstimatedFlagSurvivesEncodingAndOldDataDecodesAsNotEstimated() throws {
        let rule = ProcessingTimeRule(
            paperType: .resinCoated,
            temperatureCelsius: 20,
            timeRange: TimeRange(seconds: 90),
            isEstimated: true
        )

        let encoded = try JSONEncoder().encode(rule)
        let decoded = try JSONDecoder().decode(ProcessingTimeRule.self, from: encoded)
        XCTAssertTrue(decoded.isEstimated)

        let legacy = Data(
            #"{"paperType":"RC","temperatureCelsius":20,"timeRange":{"minimum":90,"maximum":90}}"#.utf8
        )
        let legacyDecoded = try JSONDecoder().decode(ProcessingTimeRule.self, from: legacy)
        XCTAssertFalse(legacyDecoded.isEstimated)
    }
}
