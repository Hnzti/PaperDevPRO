import Combine
import Foundation

@MainActor
final class ChemicalUsageStore: ObservableObject {
    static let shared = ChemicalUsageStore()

    @Published private(set) var counts: [String: Int]

    private let userDefaultsKey = "chemicalUsageCounts"
    private let defaults: UserDefaults

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.counts = defaults.dictionary(forKey: userDefaultsKey) as? [String: Int] ?? [:]
    }

    func count(for chemical: Chemical, dilution: ChemicalDilution) -> Int {
        counts[key(for: chemical, dilution: dilution), default: 0]
    }

    func reset(chemical: Chemical, dilution: ChemicalDilution) {
        counts[key(for: chemical, dilution: dilution)] = 0
        persist()
    }

    func recordCompletedCycle(for session: DevelopmentSession) {
        increment(chemical: session.developer, dilution: session.developerDilution)
        increment(chemical: session.stopBath, dilution: session.stopBathDilution)
        increment(chemical: session.fixer, dilution: session.fixerDilution)
    }

    private func increment(chemical: Chemical, dilution: ChemicalDilution) {
        let usageKey = key(for: chemical, dilution: dilution)
        counts[usageKey, default: 0] += 1
        persist()
    }

    private func key(for chemical: Chemical, dilution: ChemicalDilution) -> String {
        "\(chemical.id)|\(dilution.ratio)"
    }

    private func persist() {
        defaults.set(counts, forKey: userDefaultsKey)
    }
}
