import Foundation

/// Read-only catalog of everything the app knows about papers and chemistry.
/// Data lives in `PaperCatalog` / `ChemicalCatalog`; this type only queries it.
public enum DarkroomCatalog {
    public static let papers: [Paper] = PaperCatalog.all
    public static let chemicals: [Chemical] = ChemicalCatalog.all

    public static var manufacturers: [String] {
        Array(
            Set(papers.map(\.manufacturer) + chemicals.map(\.manufacturer))
        ).sorted()
    }

    public static var paperManufacturers: [String] {
        Array(Set(papers.map(\.manufacturer))).sorted()
    }

    public static var developers: [Chemical] {
        chemicals.filter { $0.role == .developer }
    }

    public static var stopBaths: [Chemical] {
        chemicals.filter { $0.role == .stopBath }
    }

    public static var fixers: [Chemical] {
        chemicals.filter { $0.role == .fixer }
    }

    public static var toners: [Chemical] {
        chemicals.filter { $0.role == .toner }
    }

    public static func paper(id: String) -> Paper? {
        papers.first { $0.id == id }
    }

    public static func chemical(id: String) -> Chemical? {
        chemicals.first { $0.id == id }
    }

    public static var defaultSession: DevelopmentSession {
        guard let paper = papers.first,
              let paperSize = paper.availableSizes.first,
              let developer = developers.first,
              let stopBath = stopBaths.first,
              let fixer = fixers.first else {
            // Shipped data, guaranteed by `DarkroomCatalogTests`.
            preconditionFailure("Catalog must contain at least one paper and one chemical per role")
        }

        return DevelopmentSession(
            paper: paper,
            paperSize: paperSize,
            developer: developer,
            developerDilution: developer.preferredDilution(for: paper),
            stopBath: stopBath,
            stopBathDilution: stopBath.preferredDilution(for: paper),
            fixer: fixer,
            fixerDilution: fixer.preferredDilution(for: paper),
            developerTemperatureCelsius: 20,
            stopBathTemperatureCelsius: 20,
            fixerTemperatureCelsius: 20
        )
    }

    @MainActor
    public static var configuredDefaultSession: DevelopmentSession {
        var session = defaultSession
        let transfer = TimeInterval(DarkroomSettingsStore.shared.defaultTransferSeconds)
        session.transferAfterDeveloperDuration = transfer
        session.transferAfterStopBathDuration = transfer
        session.transferAfterFixerDuration = transfer
        return session
    }

    /// Re-binds a stored session (preset, last used setup) to the current catalog.
    /// Presets keep full copies of papers and chemicals, so without this a datasheet
    /// correction shipped in an update would never reach saved presets. Everything the
    /// user chose (sizes, temperatures, volumes, transfers, manual overrides) is kept.
    public static func refreshed(_ session: DevelopmentSession) -> DevelopmentSession {
        var refreshed = session

        refreshed.paper = paper(id: session.paper.id) ?? session.paper
        refreshed.testStripPaper = paper(id: session.testStripPaper.id) ?? session.testStripPaper

        let developer = resolve(session.developer, dilution: session.developerDilution)
        refreshed.developer = developer.chemical
        refreshed.developerDilution = developer.dilution

        let stopBath = resolve(session.stopBath, dilution: session.stopBathDilution)
        refreshed.stopBath = stopBath.chemical
        refreshed.stopBathDilution = stopBath.dilution

        let fixer = resolve(session.fixer, dilution: session.fixerDilution)
        refreshed.fixer = fixer.chemical
        refreshed.fixerDilution = fixer.dilution

        if let storedToner = session.toner {
            let toner = resolve(storedToner, dilution: session.tonerDilution)
            refreshed.toner = toner.chemical
            refreshed.tonerDilution = toner.dilution
        }

        return refreshed
    }

    private static func resolve(
        _ storedChemical: Chemical,
        dilution storedDilution: ChemicalDilution?
    ) -> (chemical: Chemical, dilution: ChemicalDilution) {
        guard let current = chemical(id: storedChemical.id) else {
            return (storedChemical, storedDilution ?? storedChemical.dilutions.first ?? .stock)
        }

        let matchingDilution = storedDilution.flatMap { stored in
            current.dilutions.first { $0.normalizedRatio == stored.normalizedRatio }
        }

        return (current, matchingDilution ?? current.dilutions.first ?? .stock)
    }
}
