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

    var letter: String? {
        Self.letter(from: name)
    }

    static func displayName(for letter: String) -> String {
        "Preset \(letter)"
    }

    static func letter(from name: String) -> String? {
        let prefix = "Preset "
        guard name.hasPrefix(prefix) else { return nil }
        let letter = String(name.dropFirst(prefix.count))
        guard letter.count == 1, ("A"..."Z").contains(letter) else { return nil }
        return letter
    }

    static let alphabetLetters: [String] = {
        (0..<26).map { String(UnicodeScalar(UInt8(65 + $0))) }
    }()
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
              let decoded = try? JSONDecoder().decode([DevelopmentPreset].self, from: data) else {
            self.presets = []
            return
        }

        // Ponecháme jen sloty Preset A–Z (staré volné názvy zahodíme).
        self.presets = decoded
            .filter { $0.letter != nil }
            .sorted { ($0.letter ?? "") < ($1.letter ?? "") }
    }

    func preset(forLetter letter: String) -> DevelopmentPreset? {
        let name = DevelopmentPreset.displayName(for: letter)
        return presets.first { $0.name == name }
    }

    func save(letter: String, session: DevelopmentSession) {
        let name = DevelopmentPreset.displayName(for: letter)

        if let existingIndex = presets.firstIndex(where: { $0.name == name }) {
            presets[existingIndex].session = session
        } else {
            presets.append(DevelopmentPreset(name: name, session: session))
        }

        presets.sort { ($0.letter ?? "") < ($1.letter ?? "") }
        persist()
    }

    func overwrite(_ preset: DevelopmentPreset, with session: DevelopmentSession) {
        guard let index = presets.firstIndex(where: { $0.id == preset.id }) else { return }
        presets[index].session = session
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
