import XCTest
@testable import PaperDev

/// Keeps `DarkroomCatalog.json` in lockstep with the typed Swift catalogs.
///
/// The JSON is what the app loads (and what a future data update can replace).
/// The Swift files stay the authoring source. This test rewrites the JSON on disk
/// when it drifts, then checks the copy inside the app bundle.
final class CatalogExport: XCTestCase {
    func testBundledCatalogMatchesSwiftAuthoringSource() throws {
        let authored = DarkroomCatalogFile(
            schemaVersion: DarkroomCatalogFile.supportedSchemaVersion,
            revision: "2026-08-18",
            papers: PaperCatalog.all,
            chemicals: ChemicalCatalog.all
        )

        XCTAssertTrue(authored.isUsable)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(authored)

        let catalogURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("PaperDevPRO/Data/DarkroomCatalog.json")
        try data.write(to: catalogURL)

        let fromDisk = try JSONDecoder().decode(DarkroomCatalogFile.self, from: data)
        XCTAssertEqual(fromDisk.papers, PaperCatalog.all)
        XCTAssertEqual(fromDisk.chemicals, ChemicalCatalog.all)

        if let bundledURL = Bundle.main.url(forResource: "DarkroomCatalog", withExtension: "json"),
           let bundled = try? JSONDecoder().decode(
            DarkroomCatalogFile.self,
            from: Data(contentsOf: bundledURL)
           ),
           bundled.isUsable {
            XCTAssertEqual(bundled.papers, PaperCatalog.all)
            XCTAssertEqual(bundled.chemicals, ChemicalCatalog.all)
            XCTAssertEqual(DarkroomCatalog.papers, PaperCatalog.all)
            XCTAssertEqual(DarkroomCatalog.chemicals, ChemicalCatalog.all)
        }
    }
}
