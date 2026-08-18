import Foundation

/// The whole datasheet database in one versioned document.
///
/// Data lives in `DarkroomCatalog.json` inside the bundle instead of in Swift source,
/// so a datasheet correction is a data change (reviewable diff, checked by tests) and a
/// future build can ship an update without a new binary: drop a newer file with the same
/// `schemaVersion` next to the bundled one and it wins.
public struct DarkroomCatalogFile: Codable, Sendable {
    /// Bump only for breaking changes; a file with a different version is ignored.
    public static let supportedSchemaVersion = 1

    public let schemaVersion: Int
    /// Date of the datasheet review the data reflects.
    public let revision: String
    public let papers: [Paper]
    public let chemicals: [Chemical]

    public init(schemaVersion: Int, revision: String, papers: [Paper], chemicals: [Chemical]) {
        self.schemaVersion = schemaVersion
        self.revision = revision
        self.papers = papers
        self.chemicals = chemicals
    }

    /// Cheap sanity gate, so a truncated or foreign file can never replace the catalog.
    public var isUsable: Bool {
        guard schemaVersion == Self.supportedSchemaVersion,
              !papers.isEmpty,
              papers.allSatisfy({ !$0.availableSizes.isEmpty && !$0.washRules.isEmpty }),
              chemicals.allSatisfy({ !$0.dilutions.isEmpty }) else {
            return false
        }

        return ChemicalRole.required.allSatisfy { role in
            chemicals.contains { $0.role == role }
        }
    }
}

public enum DarkroomCatalogLoader {
    public static let fileName = "DarkroomCatalog"

    /// Where a downloaded data update would be stored. Nothing writes here yet; the
    /// loader already prefers it so shipping updates later needs no changes here.
    public static var updateURL: URL? {
        FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("\(fileName).json")
    }

    public static func load() -> DarkroomCatalogFile {
        if let updateURL, let update = decode(contentsOf: updateURL), update.isUsable {
            return update
        }

        if let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
           let bundled = decode(contentsOf: url),
           bundled.isUsable {
            return bundled
        }

        let embedded = DarkroomCatalogFile(
            schemaVersion: DarkroomCatalogFile.supportedSchemaVersion,
            revision: "embedded",
            papers: PaperCatalog.all,
            chemicals: ChemicalCatalog.all
        )
        precondition(embedded.isUsable, "Embedded catalog must contain papers and chemistry")
        return embedded
    }

    private static func decode(contentsOf url: URL) -> DarkroomCatalogFile? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(DarkroomCatalogFile.self, from: data)
    }
}
