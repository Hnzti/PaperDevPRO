import Combine
import Foundation

@MainActor
final class ChemicalUsageStore: ObservableObject {
    static let shared = ChemicalUsageStore()

    @Published private(set) var usages: [String: [ChemicalUsageEntry]]

    private let userDefaultsKey = "chemicalUsageEntries"
    private let legacyUserDefaultsKey = "chemicalUsageCounts"
    private let defaults: UserDefaults

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let data = defaults.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([String: [ChemicalUsageEntry]].self, from: data) {
            self.usages = decoded
        } else {
            self.usages = [:]
        }

        defaults.removeObject(forKey: legacyUserDefaultsKey)
    }

    func count(for chemical: Chemical, dilution: ChemicalDilution) -> Int {
        entries(for: chemical, dilution: dilution).count
    }

    func entries(for chemical: Chemical, dilution: ChemicalDilution) -> [ChemicalUsageEntry] {
        usages[key(for: chemical, dilution: dilution), default: []]
    }

    func reset(chemical: Chemical, dilution: ChemicalDilution) {
        usages[key(for: chemical, dilution: dilution)] = []
        persist()
    }

    func recordCompletedCycle(for session: DevelopmentSession) {
        let entry = ChemicalUsageEntry(
            paperType: session.paper.type,
            areaSquareMeters: session.paperSize.areaSquareMeters
        )

        append(entry, chemical: session.developer, dilution: session.developerDilution)
        append(entry, chemical: session.stopBath, dilution: session.stopBathDilution)
        append(entry, chemical: session.fixer, dilution: session.fixerDilution)
    }

    private func append(_ entry: ChemicalUsageEntry, chemical: Chemical, dilution: ChemicalDilution) {
        let usageKey = key(for: chemical, dilution: dilution)
        usages[usageKey, default: []].append(entry)
        persist()
    }

    private func key(for chemical: Chemical, dilution: ChemicalDilution) -> String {
        "\(chemical.id)|\(dilution.ratio)"
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(usages) else { return }
        defaults.set(data, forKey: userDefaultsKey)
    }
}
