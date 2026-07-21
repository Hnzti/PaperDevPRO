import Combine
import Foundation

struct DevelopmentPreset: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var session: DevelopmentSession

    init(id: UUID = UUID(), name: String, session: DevelopmentSession) {
        self.id = id
        self.name = name
        self.session = session
    }
}

@MainActor
final class PresetStore: ObservableObject {
    static let shared = PresetStore()

    @Published private(set) var presets: [DevelopmentPreset]

    private let userDefaultsKey = "developmentPresets"
    private let defaults: UserDefaults

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        guard let data = defaults.data(forKey: userDefaultsKey),
              let presets = try? JSONDecoder().decode([DevelopmentPreset].self, from: data) else {
            self.presets = []
            return
        }

        self.presets = presets
    }

    func save(name: String, session: DevelopmentSession) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        if let existingIndex = presets.firstIndex(where: { $0.name.caseInsensitiveCompare(trimmedName) == .orderedSame }) {
            presets[existingIndex].session = session
        } else {
            presets.append(DevelopmentPreset(name: trimmedName, session: session))
        }

        presets.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        persist()
    }

    func delete(_ preset: DevelopmentPreset) {
        presets.removeAll { $0.id == preset.id }
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(presets) else { return }
        defaults.set(data, forKey: userDefaultsKey)
    }
}
