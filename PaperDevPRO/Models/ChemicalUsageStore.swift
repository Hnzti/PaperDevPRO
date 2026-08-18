import Combine
import Foundation

@MainActor
final class ChemicalUsageStore: ObservableObject {
    static let shared = ChemicalUsageStore()

    @Published private(set) var usages: [String: [ChemicalUsageEntry]]

    /// Volume the recorded area belongs to, so a change of volume can be treated
    /// as topping up / pouring out instead of silently rescaling the history.
    @Published private(set) var volumeLiters: [String: Double]

    private let userDefaultsKey = "chemicalUsageEntries"
    private let volumeKey = "chemicalUsageVolumes"
    private let legacyUserDefaultsKey = "chemicalUsageCounts"
    private let defaults: UserDefaults

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let storedUsages = defaults.data(forKey: userDefaultsKey)
            .flatMap { Self.decodeUsages(from: $0) } ?? [:]
        self.usages = Self.normalizingKeys(storedUsages)

        self.volumeLiters = defaults.data(forKey: volumeKey)
            .flatMap { try? JSONDecoder().decode([String: Double].self, from: $0) } ?? [:]

        defaults.removeObject(forKey: legacyUserDefaultsKey)
    }

    func count(for chemical: Chemical, dilution: ChemicalDilution) -> Int {
        entries(for: chemical, dilution: dilution).count
    }

    func entries(for chemical: Chemical, dilution: ChemicalDilution) -> [ChemicalUsageEntry] {
        usages[key(for: chemical, dilution: dilution), default: []]
    }

    func reset(chemical: Chemical, dilution: ChemicalDilution) {
        let usageKey = key(for: chemical, dilution: dilution)
        usages[usageKey] = []
        volumeLiters[usageKey] = nil
        persist()
    }

    func recordCompletedCycle(for session: DevelopmentSession) {
        let entry = ChemicalUsageEntry(
            paperType: session.paper.type,
            areaSquareMeters: session.paperSize.areaSquareMeters,
            paperID: session.paper.id
        )

        append(entry, chemical: session.developer, dilution: session.developerDilution)
        append(entry, chemical: session.stopBath, dilution: session.stopBathDilution)
        append(entry, chemical: session.fixer, dilution: session.fixerDilution)

        if session.isToningEnabled,
           let toner = session.toner,
           let tonerDilution = session.tonerDilution {
            append(entry, chemical: toner, dilution: tonerDilution)
        }
    }

    /// Registers the volume currently in the tray and rebalances the recorded usage.
    ///
    /// * Topping up keeps the recorded area, so the *percentage* dilutes exactly like
    ///   the chemistry does: 1 l exhausted (0 %) + 1 l fresh (100 %) = 2 l at 50 %.
    /// * Pouring some solution out does not refresh anything, so the area shrinks with
    ///   the volume and the percentage stays where it was.
    func registerVolume(_ liters: Double, chemical: Chemical, dilution: ChemicalDilution) {
        guard liters > 0 else { return }

        let usageKey = key(for: chemical, dilution: dilution)
        let previous = volumeLiters[usageKey]

        defer {
            if volumeLiters[usageKey] != liters {
                volumeLiters[usageKey] = liters
                persist()
            }
        }

        guard let previous, previous > 0, previous != liters else { return }

        if liters < previous {
            let factor = liters / previous
            usages[usageKey] = usages[usageKey, default: []].map { $0.scalingArea(by: factor) }
        }
    }

    /// Volume the ledger was last balanced against, used by the UI to explain the state.
    func registeredVolumeLiters(for chemical: Chemical, dilution: ChemicalDilution) -> Double? {
        volumeLiters[key(for: chemical, dilution: dilution)]
    }

    private func append(_ entry: ChemicalUsageEntry, chemical: Chemical, dilution: ChemicalDilution) {
        let usageKey = key(for: chemical, dilution: dilution)
        usages[usageKey, default: []].append(entry)
        persist()
    }

    private func key(for chemical: Chemical, dilution: ChemicalDilution) -> String {
        Self.key(chemicalID: chemical.id, dilutionRatio: dilution.ratio)
    }

    private static func key(chemicalID: String, dilutionRatio: String) -> String {
        let normalizedRatio = dilutionRatio
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
        return "\(chemicalID)|\(normalizedRatio)"
    }

    /// Older builds keyed on the raw ratio (`"1 + 9"`, `"Stock"`), which produced a
    /// second history for the same bath. Merge those into the normalized key.
    private static func normalizingKeys(
        _ stored: [String: [ChemicalUsageEntry]]
    ) -> [String: [ChemicalUsageEntry]] {
        var normalized: [String: [ChemicalUsageEntry]] = [:]

        for (storedKey, entries) in stored {
            let parts = storedKey.split(separator: "|", maxSplits: 1).map(String.init)
            let newKey = parts.count == 2
                ? key(chemicalID: parts[0], dilutionRatio: parts[1])
                : storedKey
            normalized[newKey, default: []].append(contentsOf: entries)
        }

        return normalized
    }

    /// Decodes entry by entry: one unreadable record must not wipe the whole history.
    private static func decodeUsages(from data: Data) -> [String: [ChemicalUsageEntry]]? {
        let decoder = JSONDecoder()

        if let decoded = try? decoder.decode([String: [ChemicalUsageEntry]].self, from: data) {
            return decoded
        }

        guard let lossy = try? decoder.decode(
            [String: [LossyDecoded<ChemicalUsageEntry>]].self,
            from: data
        ) else {
            return nil
        }

        return lossy.mapValues { $0.compactMap(\.value) }
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(usages) {
            defaults.set(data, forKey: userDefaultsKey)
        }

        if let data = try? JSONEncoder().encode(volumeLiters) {
            defaults.set(data, forKey: volumeKey)
        }
    }
}

/// Wrapper that swallows a broken element instead of failing the whole array.
struct LossyDecoded<Value: Decodable>: Decodable {
    let value: Value?

    init(from decoder: Decoder) throws {
        value = try? Value(from: decoder)
    }
}
