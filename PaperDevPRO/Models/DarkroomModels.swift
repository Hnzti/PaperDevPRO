import Foundation

public enum PaperType: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case resinCoated = "RC"
    case fiberBased = "FB"

    public var id: String { rawValue }
}

public struct Paper: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let manufacturer: String
    public let name: String
    public let type: PaperType
    public let availableSizes: [PaperSize]
    public let washRules: [WashRule]

    public var displayName: String {
        "\(manufacturer) \(name)"
    }

    public init(
        id: String,
        manufacturer: String,
        name: String,
        type: PaperType,
        availableSizes: [PaperSize],
        washRules: [WashRule]
    ) {
        self.id = id
        self.manufacturer = manufacturer
        self.name = name
        self.type = type
        self.availableSizes = availableSizes
        self.washRules = washRules
    }

    private enum CodingKeys: String, CodingKey {
        case id, manufacturer, name, type, availableSizes, washRules
    }

    public func washDuration(for waterTemperatureCelsius: Double) -> TimeInterval {
        if let rule = washRules.first(where: { $0.matches(temperatureCelsius: waterTemperatureCelsius) }) {
            return rule.duration
        }

        // Colder than any documented rule: washing only gets slower, never faster,
        // so fall back to the longest documented time instead of reporting 0 s.
        return washRules.map(\.duration).max() ?? 0
    }

}

public enum LengthUnit: String, Codable, Hashable, Sendable {
    case centimeters
    case inches

    public var symbol: String {
        switch self {
        case .centimeters: return "cm"
        case .inches: return "in"
        }
    }
}

public struct PaperSize: Identifiable, Codable, Hashable, Sendable {
    public let widthCentimeters: Double
    public let heightCentimeters: Double
    /// Unit the size is cut and sold in. ILFORD sells 8×10 in and 18×24 cm side by
    /// side, so each size is shown the way its datasheet prints it; the conversion
    /// is only added when the user works in the other unit.
    public let nativeUnit: LengthUnit

    /// Identity in tenths of a millimetre. Formatting the raw `Double`s produced ids
    /// like `7.619999999999999x25.4`, so the same piece of paper (catalog value vs.
    /// value computed from inches) compared as different and the picker lost its
    /// selection. The native unit is deliberately not part of the identity.
    public var id: String {
        "\(Self.tenthsOfMillimeter(widthCentimeters))x\(Self.tenthsOfMillimeter(heightCentimeters))"
    }

    /// Size as printed in the manufacturer's datasheet.
    public var displayName: String {
        displayName(in: nativeUnit)
    }

    public var areaSquareMeters: Double {
        (widthCentimeters / 100) * (heightCentimeters / 100)
    }

    public init(
        widthCentimeters: Double,
        heightCentimeters: Double,
        nativeUnit: LengthUnit = .centimeters
    ) {
        self.widthCentimeters = widthCentimeters
        self.heightCentimeters = heightCentimeters
        self.nativeUnit = nativeUnit
    }

    /// Size given in inches by the datasheet (4×5, 8×10, 16×20 …).
    public static func inches(width: Double, height: Double) -> PaperSize {
        PaperSize(
            widthCentimeters: width * 2.54,
            heightCentimeters: height * 2.54,
            nativeUnit: .inches
        )
    }

    public func displayName(in unit: LengthUnit) -> String {
        let divisor = unit == .inches ? 2.54 : 1
        let width = Self.formatted(widthCentimeters / divisor)
        let height = Self.formatted(heightCentimeters / divisor)
        return "\(width) x \(height) \(unit.symbol)"
    }

    private enum CodingKeys: String, CodingKey {
        case widthCentimeters, heightCentimeters, nativeUnit
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        widthCentimeters = try container.decode(Double.self, forKey: .widthCentimeters)
        heightCentimeters = try container.decode(Double.self, forKey: .heightCentimeters)
        nativeUnit = try container.decodeIfPresent(LengthUnit.self, forKey: .nativeUnit) ?? .centimeters
    }

    private static func formatted(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...1)))
    }

    private static func tenthsOfMillimeter(_ centimeters: Double) -> Int {
        Int((centimeters * 100).rounded())
    }
}

public struct WashRule: Codable, Hashable, Sendable {
    public let minimumTemperatureCelsius: Double?
    public let maximumTemperatureCelsius: Double?
    public let duration: TimeInterval

    public init(
        minimumTemperatureCelsius: Double? = nil,
        maximumTemperatureCelsius: Double? = nil,
        duration: TimeInterval
    ) {
        self.minimumTemperatureCelsius = minimumTemperatureCelsius
        self.maximumTemperatureCelsius = maximumTemperatureCelsius
        self.duration = duration
    }

    public func matches(temperatureCelsius: Double) -> Bool {
        if let minimumTemperatureCelsius, temperatureCelsius < minimumTemperatureCelsius {
            return false
        }

        if let maximumTemperatureCelsius, temperatureCelsius < maximumTemperatureCelsius {
            return true
        }

        return maximumTemperatureCelsius == nil
    }
}

/// Post-toning wash from the toner datasheet (RC vs FB). When a toner has none,
/// the paper's ordinary wash rules are used.
public struct PostToningWashRule: Codable, Hashable, Sendable {
    public let paperType: PaperType
    public let minimumTemperatureCelsius: Double?
    public let duration: TimeInterval

    public init(
        paperType: PaperType,
        minimumTemperatureCelsius: Double? = nil,
        duration: TimeInterval
    ) {
        self.paperType = paperType
        self.minimumTemperatureCelsius = minimumTemperatureCelsius
        self.duration = duration
    }

    public func matches(temperatureCelsius: Double) -> Bool {
        if let minimumTemperatureCelsius, temperatureCelsius < minimumTemperatureCelsius {
            return false
        }
        return true
    }
}

public enum ProcessPhase: String, CaseIterable, Codable, Hashable, Identifiable, Sendable {
    case developer
    case transferToStopBath
    case stopBath
    case transferToFixer
    case fixer
    case transferToWash
    case wash
    case transferToToning
    case toning
    case transferToWashAfterToning
    case washAfterToning

    public var id: String { rawValue }

    /// Titles shown to the user come from `AppCopy.phaseTitle(_:)`, never from the model.
    public var isTransfer: Bool {
        switch self {
        case .transferToStopBath, .transferToFixer, .transferToWash, .transferToToning, .transferToWashAfterToning:
            return true
        default:
            return false
        }
    }
}

public enum ChemicalRole: String, Codable, Hashable, CaseIterable, Sendable {
    case developer
    case stopBath
    case fixer
    case toner

    /// Roles a session cannot be built without.
    public static let required: [ChemicalRole] = [.developer, .stopBath, .fixer]

    public var phase: ProcessPhase {
        switch self {
        case .developer:
            return .developer
        case .stopBath:
            return .stopBath
        case .fixer:
            return .fixer
        case .toner:
            return .toning
        }
    }
}

public struct ChemicalDilution: Identifiable, Codable, Hashable, Sendable {
    public let ratio: String
    public let timeRules: [ProcessingTimeRule]
    public let capacityRules: [ChemicalCapacityRule]
    public let postToningWashRules: [PostToningWashRule]

    public var id: String { ratio }

    /// Used when a chemical arrives without any dilution (corrupt preset, future data file).
    public static let stock = ChemicalDilution(ratio: "stock")

    /// Stable key for the usage ledger: `1 + 9`, `1+9` and `Stock` must not create
    /// three separate histories for the same bath.
    public var normalizedRatio: String {
        ratio.lowercased().replacingOccurrences(of: " ", with: "")
    }

    public init(
        ratio: String,
        timeRules: [ProcessingTimeRule] = [],
        capacityRules: [ChemicalCapacityRule] = [],
        postToningWashRules: [PostToningWashRule] = []
    ) {
        self.ratio = ratio
        self.timeRules = timeRules
        self.capacityRules = capacityRules
        self.postToningWashRules = postToningWashRules
    }

    private enum CodingKeys: String, CodingKey {
        case ratio, timeRules, capacityRules, postToningWashRules
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ratio = try container.decode(String.self, forKey: .ratio)
        timeRules = try container.decodeIfPresent([ProcessingTimeRule].self, forKey: .timeRules) ?? []
        capacityRules = try container.decodeIfPresent([ChemicalCapacityRule].self, forKey: .capacityRules) ?? []
        postToningWashRules = try container.decodeIfPresent(
            [PostToningWashRule].self,
            forKey: .postToningWashRules
        ) ?? []
    }

    /// Wash after toning from this dilution's datasheet. `nil` means use the paper wash.
    public func postToningWashDuration(
        for paper: Paper,
        waterTemperatureCelsius: Double
    ) -> TimeInterval? {
        let matching = postToningWashRules.filter { $0.paperType == paper.type }
        guard !matching.isEmpty else { return nil }

        if let rule = matching.first(where: { $0.matches(temperatureCelsius: waterTemperatureCelsius) }) {
            return rule.duration
        }

        return matching.map(\.duration).max()
    }

    public func availableTemperatures(for paper: Paper, chemicalManufacturer: String) -> [Double] {
        let temperatures = rules(for: paper, chemicalManufacturer: chemicalManufacturer)
            .map(\.temperatureCelsius)
        let uniqueTemperatures = Array(Set(temperatures)).sorted()

        guard let minimum = uniqueTemperatures.first,
              let maximum = uniqueTemperatures.last,
              minimum != maximum else {
            return uniqueTemperatures
        }

        return Array(Int(minimum.rounded())...Int(maximum.rounded())).map(Double.init)
    }

    /// True když pro papír existuje aspoň jedno explicitní pravidlo v datasheetu
    /// (podle `paperID`, jinak podle typu RC/FB u stejné značky). Nezohledňuje teplotu.
    public func isDocumented(for paper: Paper, chemicalManufacturer: String) -> Bool {
        !documentedRules(for: paper, chemicalManufacturer: chemicalManufacturer).isEmpty
    }

    /// True když pro papír máme použitelné pravidlo – i když je to jen výrobcem
    /// doporučený odhad (`isEstimated`). Rozhoduje o tom, co se nabídne v pickeru;
    /// o pečeť vs. vykřičník rozhoduje `isDocumented`.
    public func isApplicable(for paper: Paper, chemicalManufacturer: String) -> Bool {
        !applicableRules(for: paper, chemicalManufacturer: chemicalManufacturer).isEmpty
    }

    /// True jen když je zobrazený čas **přesně** z datasheetu pro daný papír
    /// **a** zvolenou teplotu. Interpolace mezi teplotami (např. 34 °C mezi 30 a 35)
    /// nebo fallback z jiného papíru = false → vykřičník.
    public func isDocumented(
        for paper: Paper,
        temperatureCelsius: Double,
        chemicalManufacturer: String
    ) -> Bool {
        documentedRules(for: paper, chemicalManufacturer: chemicalManufacturer)
            .contains { $0.temperatureCelsius == temperatureCelsius }
    }

    /// Teploty přímo uvedené v datasheetu pro daný papír (bez vyplnění mezikroků).
    public func documentedTemperatures(for paper: Paper, chemicalManufacturer: String) -> [Double] {
        Array(
            Set(
                documentedRules(for: paper, chemicalManufacturer: chemicalManufacturer)
                    .map(\.temperatureCelsius)
            )
        ).sorted()
    }

    public func timeRange(
        for paper: Paper,
        temperatureCelsius: Double,
        chemicalManufacturer: String
    ) -> TimeRange {
        let rules = rules(for: paper, chemicalManufacturer: chemicalManufacturer)

        if let exactRule = rules.first(where: { $0.temperatureCelsius == temperatureCelsius }) {
            return exactRule.timeRange
        }

        guard let firstRule = rules.first else {
            return TimeRange(seconds: 60)
        }

        if temperatureCelsius <= firstRule.temperatureCelsius {
            return firstRule.timeRange
        }

        guard let lastRule = rules.last else {
            return firstRule.timeRange
        }

        if temperatureCelsius >= lastRule.temperatureCelsius {
            return lastRule.timeRange
        }

        guard let upperRule = rules.first(where: { $0.temperatureCelsius > temperatureCelsius }),
              let lowerRule = rules.last(where: { $0.temperatureCelsius < temperatureCelsius }) else {
            return firstRule.timeRange
        }

        return TimeRange.interpolate(
            from: lowerRule.timeRange,
            at: lowerRule.temperatureCelsius,
            to: upperRule.timeRange,
            at: upperRule.temperatureCelsius,
            targetTemperature: temperatureCelsius
        )
    }

    /// Zbývající vydatnost v procentech. Vydatnost je vždy plošná kapacita
    /// **na litr** × objem roztoku, takže větší vana = víc papíru.
    public func capacityPercent(
        usages: [ChemicalUsageEntry],
        workingSolutionLiters: Double
    ) -> Int? {
        guard workingSolutionLiters > 0, !capacityRules.isEmpty else {
            return nil
        }

        var usedFraction = 0.0

        for usage in usages {
            guard let rule = capacityRule(for: usage) else {
                continue
            }

            let capacityArea = rule.squareMetersPerLiter * workingSolutionLiters
            guard capacityArea > 0 else { continue }

            usedFraction += usage.areaSquareMeters / capacityArea
        }

        let remainingRatio = max(0, 1 - usedFraction)
        return Int((remainingRatio * 100).rounded())
    }

    public func mixComponents(totalMilliliters: Int) -> DilutionMix {
        let normalizedRatio = ratio
            .lowercased()
            .replacingOccurrences(of: " ", with: "")

        if normalizedRatio == "stock" || normalizedRatio == "neředěný" || normalizedRatio == "working solution" {
            return DilutionMix(chemicalMilliliters: totalMilliliters, waterMilliliters: 0)
        }

        let parts = normalizedRatio
            .split(separator: "+")
            .compactMap { Double($0) }

        guard parts.count == 2 else {
            return DilutionMix(chemicalMilliliters: totalMilliliters, waterMilliliters: 0)
        }

        let chemicalParts = parts[0]
        let waterParts = parts[1]
        let allParts = chemicalParts + waterParts
        guard allParts > 0 else {
            return DilutionMix(chemicalMilliliters: totalMilliliters, waterMilliliters: 0)
        }

        let chemicalMilliliters = Int((Double(totalMilliliters) * chemicalParts / allParts).rounded())
        return DilutionMix(
            chemicalMilliliters: chemicalMilliliters,
            waterMilliliters: max(0, totalMilliliters - chemicalMilliliters)
        )
    }

    /// Kapacita pro konkrétní papír: nejdřív pravidlo přímo pro `paperID`
    /// (např. MG RC Cooltone má poloviční vydatnost vývojky), pak podle typu.
    private func capacityRule(for usage: ChemicalUsageEntry) -> ChemicalCapacityRule? {
        if let paperID = usage.paperID,
           let rule = capacityRules.first(where: { $0.paperID == paperID }) {
            return rule
        }

        return capacityRules.first { $0.paperID == nil && $0.paperType == usage.paperType }
    }

    /// Pravidla použitelná pro papír – i odhady (`isEstimated`):
    /// 1) explicitní `paperID`, jinak 2) `paperType` jen u **stejné značky / rodiny**.
    private func applicableRules(
        for paper: Paper,
        chemicalManufacturer: String
    ) -> [ProcessingTimeRule] {
        let exactRules = timeRules.filter { $0.paperID == paper.id }
        if !exactRules.isEmpty {
            return exactRules
        }

        guard DarkroomBrandFamily.sharesDocumentation(chemicalManufacturer, paper.manufacturer) else {
            return []
        }

        return timeRules.filter { $0.paperID == nil && $0.paperType == paper.type }
    }

    /// Pravidla, která jsou pro papír „oficiální“ – bez odhadů. Jen tyto smí
    /// zobrazit pečeť.
    private func documentedRules(
        for paper: Paper,
        chemicalManufacturer: String
    ) -> [ProcessingTimeRule] {
        applicableRules(for: paper, chemicalManufacturer: chemicalManufacturer)
            .filter { !$0.isEstimated }
    }

    /// Pravidla použitá pro výpočet času. Když pro kombinaci nic nemáme, bere se
    /// nejbližší příbuzná sada (stejný typ papíru), a to v deterministickém pořadí –
    /// dřív mohl výsledek záležet na pořadí v katalogu.
    private func rules(
        for paper: Paper,
        chemicalManufacturer: String
    ) -> [ProcessingTimeRule] {
        let applicable = applicableRules(for: paper, chemicalManufacturer: chemicalManufacturer)
        if !applicable.isEmpty {
            return Self.deterministicallySorted(applicable)
        }

        let sameTypeRules = timeRules.filter { $0.paperType == paper.type }
        return Self.deterministicallySorted(sameTypeRules.isEmpty ? timeRules : sameTypeRules)
    }

    private static func deterministicallySorted(
        _ rules: [ProcessingTimeRule]
    ) -> [ProcessingTimeRule] {
        rules.sorted { lhs, rhs in
            if lhs.temperatureCelsius != rhs.temperatureCelsius {
                return lhs.temperatureCelsius < rhs.temperatureCelsius
            }
            if lhs.timeRange.recommended != rhs.timeRange.recommended {
                return lhs.timeRange.recommended < rhs.timeRange.recommended
            }
            return (lhs.paperID ?? "") < (rhs.paperID ?? "")
        }
    }
}

public struct DilutionMix: Codable, Hashable, Sendable {
    public let chemicalMilliliters: Int
    public let waterMilliliters: Int
}

public struct ChemicalCapacityRule: Codable, Hashable, Sendable {
    /// Nepovinné zúžení na jeden papír (datasheet uvádí u některých papírů
    /// odlišnou vydatnost než u zbytku typu).
    public let paperID: String?
    public let paperType: PaperType
    public let squareMetersPerLiter: Double

    public init(paperID: String? = nil, paperType: PaperType, squareMetersPerLiter: Double) {
        self.paperID = paperID
        self.paperType = paperType
        self.squareMetersPerLiter = squareMetersPerLiter
    }
}

public struct ChemicalUsageEntry: Codable, Hashable, Sendable {
    public let paperType: PaperType
    public let areaSquareMeters: Double
    /// Doplněno později; starší záznamy ho nemají a počítají se podle typu papíru.
    public let paperID: String?

    public init(paperType: PaperType, areaSquareMeters: Double, paperID: String? = nil) {
        self.paperType = paperType
        self.areaSquareMeters = areaSquareMeters
        self.paperID = paperID
    }

    /// Stejný záznam s přepočtenou plochou – používá se při změně objemu roztoku.
    public func scalingArea(by factor: Double) -> ChemicalUsageEntry {
        ChemicalUsageEntry(
            paperType: paperType,
            areaSquareMeters: areaSquareMeters * factor,
            paperID: paperID
        )
    }
}

public struct ProcessingTimeRule: Codable, Hashable, Sendable {
    public let paperID: String?
    public let paperType: PaperType?
    public let temperatureCelsius: Double
    public let timeRange: TimeRange
    /// `true` = čas není v datasheetu, jen odvozený/odhadnutý. Používá se pro výpočet,
    /// ale nikdy nesmí zobrazit pečeť „přesně dle dokumentace“.
    public let isEstimated: Bool

    public init(
        paperID: String? = nil,
        paperType: PaperType? = nil,
        temperatureCelsius: Double,
        timeRange: TimeRange,
        isEstimated: Bool = false
    ) {
        self.paperID = paperID
        self.paperType = paperType
        self.temperatureCelsius = temperatureCelsius
        self.timeRange = timeRange
        self.isEstimated = isEstimated
    }

    private enum CodingKeys: String, CodingKey {
        case paperID, paperType, temperatureCelsius, timeRange, isEstimated
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        paperID = try container.decodeIfPresent(String.self, forKey: .paperID)
        paperType = try container.decodeIfPresent(PaperType.self, forKey: .paperType)
        temperatureCelsius = try container.decode(Double.self, forKey: .temperatureCelsius)
        timeRange = try container.decode(TimeRange.self, forKey: .timeRange)
        isEstimated = try container.decodeIfPresent(Bool.self, forKey: .isEstimated) ?? false
    }
}

public struct TimeRange: Codable, Hashable, Sendable {
    public let minimum: TimeInterval
    public let maximum: TimeInterval

    public var recommended: TimeInterval {
        if minimum == maximum {
            return minimum.rounded()
        }
        return ((minimum + maximum) / 2).rounded()
    }

    public init(seconds: TimeInterval) {
        self.minimum = seconds
        self.maximum = seconds
    }

    public init(minimum: TimeInterval, maximum: TimeInterval) {
        self.minimum = minimum
        self.maximum = maximum
    }

    public static func interpolate(
        from lowerRange: TimeRange,
        at lowerTemperature: Double,
        to upperRange: TimeRange,
        at upperTemperature: Double,
        targetTemperature: Double
    ) -> TimeRange {
        guard lowerTemperature != upperTemperature else {
            return lowerRange
        }

        let progress = (targetTemperature - lowerTemperature) / (upperTemperature - lowerTemperature)
        let minimum = lowerRange.minimum + ((upperRange.minimum - lowerRange.minimum) * progress)
        let maximum = lowerRange.maximum + ((upperRange.maximum - lowerRange.maximum) * progress)
        return TimeRange(minimum: minimum.rounded(), maximum: maximum.rounded())
    }

    public var displayText: String {
        if minimum == maximum {
            return formatDuration(maximum)
        }

        return "\(formatDuration(minimum))-\(formatDuration(maximum))"
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration.rounded())
        return "\(totalSeconds) s"
    }
}

public struct Chemical: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let manufacturer: String
    public let name: String
    public let role: ChemicalRole
    public let dilutions: [ChemicalDilution]

    public var displayName: String {
        "\(manufacturer) \(name)"
    }

    /// True když je pro daný papír zdokumentovaná alespoň jedna kombinace
    /// (ředění) v datasheetu stejné značky / HARMAN rodiny, nebo explicitní `paperID`.
    public func isDocumented(for paper: Paper) -> Bool {
        if dilutions.contains(where: {
            $0.isDocumented(for: paper, chemicalManufacturer: manufacturer)
        }) {
            return true
        }

        // Tónovače často nemají pevný čas, ale mají vydatnost podle typu papíru.
        guard role == .toner,
              DarkroomBrandFamily.sharesDocumentation(manufacturer, paper.manufacturer) else {
            return false
        }

        return dilutions.contains { dilution in
            dilution.capacityRules.contains { $0.paperType == paper.type }
        }
    }

    /// True když pro papír existuje použitelný čas nebo vydatnost – včetně
    /// výrobcem odvozených odhadů. Podle toho se chemie nabízí v pickeru.
    public func isApplicable(for paper: Paper) -> Bool {
        if dilutions.contains(where: {
            $0.isApplicable(for: paper, chemicalManufacturer: manufacturer)
        }) {
            return true
        }

        // Tónovač s vydatností nebo časem podle typu papíru je použitelný
        // i na papír jiné značky (datasheet Selenium: RC i FB obecně).
        guard role == .toner else {
            return false
        }

        return dilutions.contains { dilution in
            dilution.timeRules.contains { $0.paperID == nil && $0.paperType == paper.type }
                || dilution.capacityRules.contains { $0.paperID == nil && $0.paperType == paper.type }
        }
    }

    public func preferredDilution(for paper: Paper) -> ChemicalDilution {
        dilutions.first { $0.isDocumented(for: paper, chemicalManufacturer: manufacturer) }
            ?? dilutions.first { $0.isApplicable(for: paper, chemicalManufacturer: manufacturer) }
            ?? dilutions.first
            ?? .stock
    }

    public init(
        id: String,
        manufacturer: String,
        name: String,
        role: ChemicalRole,
        dilutions: [ChemicalDilution]
    ) {
        self.id = id
        self.manufacturer = manufacturer
        self.name = name
        self.role = role
        self.dilutions = dilutions
    }
}

/// Ilford / Kentmere / HARMAN sdílí datasheetovou kompatibilitu chemie ↔ papír.
enum DarkroomBrandFamily {
    static func sharesDocumentation(_ lhs: String, _ rhs: String) -> Bool {
        if lhs.caseInsensitiveCompare(rhs) == .orderedSame {
            return true
        }
        return isHarmanFamily(lhs) && isHarmanFamily(rhs)
    }

    static func isHarmanFamily(_ manufacturer: String) -> Bool {
        switch manufacturer.lowercased() {
        case "ilford", "kentmere", "harman":
            return true
        default:
            return false
        }
    }
}

public struct TimedProcessPhase: Identifiable, Codable, Hashable, Sendable {
    public let phase: ProcessPhase
    public let duration: TimeInterval
    public let requiresManualContinue: Bool

    public var id: ProcessPhase { phase }

    public init(phase: ProcessPhase, duration: TimeInterval, requiresManualContinue: Bool = false) {
        self.phase = phase
        self.duration = duration
        self.requiresManualContinue = requiresManualContinue
    }

    private enum CodingKeys: String, CodingKey {
        case phase, duration, requiresManualContinue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        phase = try container.decode(ProcessPhase.self, forKey: .phase)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        requiresManualContinue = try container.decodeIfPresent(Bool.self, forKey: .requiresManualContinue) ?? false
    }
}

public struct DevelopmentSession: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var paper: Paper
    public var paperSize: PaperSize
    public var testStripPaper: Paper
    public var testStripPaperSize: PaperSize
    /// When off (the default), a test strip ends after fixer: no last transfer, no wash.
    public var isTestStripWashEnabled: Bool
    public var developer: Chemical
    public var developerDilution: ChemicalDilution
    public var stopBath: Chemical
    public var stopBathDilution: ChemicalDilution
    public var fixer: Chemical
    public var fixerDilution: ChemicalDilution
    public var developerTemperatureCelsius: Double
    public var stopBathTemperatureCelsius: Double
    public var fixerTemperatureCelsius: Double
    public var developerVolumeMilliliters: Int
    public var stopBathVolumeMilliliters: Int
    public var fixerVolumeMilliliters: Int
    public var transferAfterDeveloperDuration: TimeInterval
    public var transferAfterStopBathDuration: TimeInterval
    public var transferAfterFixerDuration: TimeInterval
    public var transferAfterWashDuration: TimeInterval
    public var transferAfterToningDuration: TimeInterval
    public var washTemperatureCelsius: Double
    public var isToningEnabled: Bool
    /// Visual (no printed time) toning waits for RESUME instead of counting down.
    public var isToningManualContinue: Bool
    public var toner: Chemical?
    public var tonerDilution: ChemicalDilution?
    public var toningTemperatureCelsius: Double
    public var toningVolumeMilliliters: Int
    public var toningDuration: TimeInterval
    public var phaseDurationOverrides: [ProcessPhase: TimeInterval]

    public init(
        id: UUID = UUID(),
        paper: Paper,
        paperSize: PaperSize,
        testStripPaper: Paper? = nil,
        testStripPaperSize: PaperSize? = nil,
        isTestStripWashEnabled: Bool = false,
        developer: Chemical,
        developerDilution: ChemicalDilution,
        stopBath: Chemical,
        stopBathDilution: ChemicalDilution,
        fixer: Chemical,
        fixerDilution: ChemicalDilution,
        developerTemperatureCelsius: Double,
        stopBathTemperatureCelsius: Double,
        fixerTemperatureCelsius: Double,
        developerVolumeMilliliters: Int = 1_000,
        stopBathVolumeMilliliters: Int = 1_000,
        fixerVolumeMilliliters: Int = 1_000,
        transferAfterDeveloperDuration: TimeInterval = 10,
        transferAfterStopBathDuration: TimeInterval = 10,
        transferAfterFixerDuration: TimeInterval = 10,
        transferAfterWashDuration: TimeInterval = 10,
        transferAfterToningDuration: TimeInterval = 10,
        washTemperatureCelsius: Double = 20,
        isToningEnabled: Bool = false,
        isToningManualContinue: Bool = true,
        toner: Chemical? = nil,
        tonerDilution: ChemicalDilution? = nil,
        toningTemperatureCelsius: Double = 25,
        toningVolumeMilliliters: Int = 5_000,
        toningDuration: TimeInterval = 300,
        phaseDurationOverrides: [ProcessPhase: TimeInterval] = [:]
    ) {
        self.id = id
        self.paper = paper
        self.paperSize = paperSize
        self.testStripPaper = testStripPaper ?? paper
        self.testStripPaperSize = testStripPaperSize
            ?? (testStripPaper ?? paper).availableSizes.first
            ?? PaperSize(widthCentimeters: 2.5, heightCentimeters: 10)
        self.isTestStripWashEnabled = isTestStripWashEnabled
        self.developer = developer
        self.developerDilution = developerDilution
        self.stopBath = stopBath
        self.stopBathDilution = stopBathDilution
        self.fixer = fixer
        self.fixerDilution = fixerDilution
        self.developerTemperatureCelsius = developerTemperatureCelsius
        self.stopBathTemperatureCelsius = stopBathTemperatureCelsius
        self.fixerTemperatureCelsius = fixerTemperatureCelsius
        self.developerVolumeMilliliters = developerVolumeMilliliters
        self.stopBathVolumeMilliliters = stopBathVolumeMilliliters
        self.fixerVolumeMilliliters = fixerVolumeMilliliters
        self.transferAfterDeveloperDuration = transferAfterDeveloperDuration
        self.transferAfterStopBathDuration = transferAfterStopBathDuration
        self.transferAfterFixerDuration = transferAfterFixerDuration
        self.transferAfterWashDuration = transferAfterWashDuration
        self.transferAfterToningDuration = transferAfterToningDuration
        self.washTemperatureCelsius = washTemperatureCelsius
        self.isToningEnabled = isToningEnabled
        self.isToningManualContinue = isToningManualContinue
        self.toner = toner
        self.tonerDilution = tonerDilution
        self.toningTemperatureCelsius = toningTemperatureCelsius
        self.toningVolumeMilliliters = toningVolumeMilliliters
        self.toningDuration = toningDuration
        self.phaseDurationOverrides = phaseDurationOverrides
    }

    /// Session pro běh proužkové zkoušky – časy i vydatnost berou typ/rozměr ze sekce Papír zkouška.
    public func testStripRunSession() -> DevelopmentSession {
        var copy = self
        copy.paper = testStripPaper
        copy.paperSize = testStripPaperSize
        if !isTestStripWashEnabled {
            copy.isToningEnabled = false
        }
        return copy
    }

    // Zpětně kompatibilní dekódování – starší presety nemají nové klíče,
    // proto pro chybějící hodnoty dosadíme rozumné výchozí hodnoty.
    private enum CodingKeys: String, CodingKey {
        case id, paper, paperSize, testStripPaper, testStripPaperSize, isTestStripWashEnabled
        case developer, developerDilution
        case stopBath, stopBathDilution, fixer, fixerDilution
        case developerTemperatureCelsius, stopBathTemperatureCelsius, fixerTemperatureCelsius
        case developerVolumeMilliliters, stopBathVolumeMilliliters, fixerVolumeMilliliters
        case transferAfterDeveloperDuration, transferAfterStopBathDuration, transferAfterFixerDuration
        case transferAfterWashDuration, transferAfterToningDuration
        case washTemperatureCelsius, isToningEnabled, isToningManualContinue, toner, tonerDilution
        case toningTemperatureCelsius, toningVolumeMilliliters, toningDuration
        case phaseDurationOverrides
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        paper = try container.decode(Paper.self, forKey: .paper)
        paperSize = try container.decode(PaperSize.self, forKey: .paperSize)
        testStripPaper = try container.decodeIfPresent(Paper.self, forKey: .testStripPaper) ?? paper
        testStripPaperSize = try container.decodeIfPresent(PaperSize.self, forKey: .testStripPaperSize)
            ?? testStripPaper.availableSizes.first
            ?? PaperSize(widthCentimeters: 2.5, heightCentimeters: 10)
        isTestStripWashEnabled = try container.decodeIfPresent(Bool.self, forKey: .isTestStripWashEnabled) ?? false
        developer = try container.decode(Chemical.self, forKey: .developer)
        developerDilution = try container.decode(ChemicalDilution.self, forKey: .developerDilution)
        stopBath = try container.decode(Chemical.self, forKey: .stopBath)
        stopBathDilution = try container.decode(ChemicalDilution.self, forKey: .stopBathDilution)
        fixer = try container.decode(Chemical.self, forKey: .fixer)
        fixerDilution = try container.decode(ChemicalDilution.self, forKey: .fixerDilution)
        developerTemperatureCelsius = try container.decode(Double.self, forKey: .developerTemperatureCelsius)
        stopBathTemperatureCelsius = try container.decode(Double.self, forKey: .stopBathTemperatureCelsius)
        fixerTemperatureCelsius = try container.decode(Double.self, forKey: .fixerTemperatureCelsius)
        developerVolumeMilliliters = try container.decode(Int.self, forKey: .developerVolumeMilliliters)
        stopBathVolumeMilliliters = try container.decode(Int.self, forKey: .stopBathVolumeMilliliters)
        fixerVolumeMilliliters = try container.decode(Int.self, forKey: .fixerVolumeMilliliters)
        transferAfterDeveloperDuration = try container.decode(TimeInterval.self, forKey: .transferAfterDeveloperDuration)
        transferAfterStopBathDuration = try container.decode(TimeInterval.self, forKey: .transferAfterStopBathDuration)
        transferAfterFixerDuration = try container.decode(TimeInterval.self, forKey: .transferAfterFixerDuration)
        transferAfterWashDuration = try container.decodeIfPresent(TimeInterval.self, forKey: .transferAfterWashDuration)
            ?? transferAfterFixerDuration
        transferAfterToningDuration = try container.decodeIfPresent(TimeInterval.self, forKey: .transferAfterToningDuration)
            ?? transferAfterFixerDuration
        washTemperatureCelsius = try container.decodeIfPresent(Double.self, forKey: .washTemperatureCelsius)
            ?? fixerTemperatureCelsius
        isToningEnabled = try container.decodeIfPresent(Bool.self, forKey: .isToningEnabled) ?? false
        isToningManualContinue = try container.decodeIfPresent(Bool.self, forKey: .isToningManualContinue) ?? true
        toner = try container.decodeIfPresent(Chemical.self, forKey: .toner)
        tonerDilution = try container.decodeIfPresent(ChemicalDilution.self, forKey: .tonerDilution)
        toningTemperatureCelsius = try container.decodeIfPresent(Double.self, forKey: .toningTemperatureCelsius) ?? 25
        toningVolumeMilliliters = try container.decodeIfPresent(Int.self, forKey: .toningVolumeMilliliters) ?? 5_000
        toningDuration = try container.decodeIfPresent(TimeInterval.self, forKey: .toningDuration) ?? 300
        phaseDurationOverrides = try container.decodeIfPresent(
            [ProcessPhase: TimeInterval].self,
            forKey: .phaseDurationOverrides
        ) ?? [:]
    }

    public func resolvedPhases(forTestStrip: Bool = false) -> [TimedProcessPhase] {
        let includeWash = !forTestStrip || isTestStripWashEnabled
        var phases: [TimedProcessPhase] = [
            TimedProcessPhase(
                phase: .developer,
                duration: duration(
                    for: .developer,
                    defaultDuration: developerDilution
                        .timeRange(
                            for: paper,
                            temperatureCelsius: developerTemperatureCelsius,
                            chemicalManufacturer: developer.manufacturer
                        )
                        .recommended
                )
            ),
            TimedProcessPhase(
                phase: .transferToStopBath,
                duration: duration(for: .transferToStopBath, defaultDuration: transferAfterDeveloperDuration)
            ),
            TimedProcessPhase(
                phase: .stopBath,
                duration: duration(
                    for: .stopBath,
                    defaultDuration: stopBathDilution
                        .timeRange(
                            for: paper,
                            temperatureCelsius: stopBathTemperatureCelsius,
                            chemicalManufacturer: stopBath.manufacturer
                        )
                        .recommended
                )
            ),
            TimedProcessPhase(
                phase: .transferToFixer,
                duration: duration(for: .transferToFixer, defaultDuration: transferAfterStopBathDuration)
            ),
            TimedProcessPhase(
                phase: .fixer,
                duration: duration(
                    for: .fixer,
                    defaultDuration: fixerDilution
                        .timeRange(
                            for: paper,
                            temperatureCelsius: fixerTemperatureCelsius,
                            chemicalManufacturer: fixer.manufacturer
                        )
                        .recommended
                )
            )
        ]

        if includeWash {
            phases.append(
                TimedProcessPhase(
                    phase: .transferToWash,
                    duration: duration(for: .transferToWash, defaultDuration: transferAfterFixerDuration)
                )
            )
            phases.append(
                TimedProcessPhase(
                    phase: .wash,
                    duration: duration(for: .wash, defaultDuration: paper.washDuration(for: washTemperatureCelsius))
                )
            )

            if isToningEnabled {
                phases.append(
                    TimedProcessPhase(
                        phase: .transferToToning,
                        duration: duration(for: .transferToToning, defaultDuration: transferAfterWashDuration)
                    )
                )
                let waitsForContinue = waitsForVisualToningContinue
                phases.append(
                    TimedProcessPhase(
                        phase: .toning,
                        duration: waitsForContinue
                            ? 0
                            : duration(for: .toning, defaultDuration: datasheetToningDuration),
                        requiresManualContinue: waitsForContinue
                    )
                )
                phases.append(
                    TimedProcessPhase(
                        phase: .transferToWashAfterToning,
                        duration: duration(
                            for: .transferToWashAfterToning,
                            defaultDuration: transferAfterToningDuration
                        )
                    )
                )
                phases.append(
                    TimedProcessPhase(
                        phase: .washAfterToning,
                        duration: duration(for: .washAfterToning, defaultDuration: datasheetWashAfterToningDuration)
                    )
                )
            }
        }

        return phases
    }

    /// Datasheet time for the chosen toner/dilution/paper/temperature.
    /// Visual-only dilutions (no printed time) wait for RESUME, or run 3 minutes
    /// if manual continue is off.
    private var datasheetToningDuration: TimeInterval {
        guard let toner, let tonerDilution, !tonerDilution.timeRules.isEmpty else {
            return 180
        }

        return tonerDilution
            .timeRange(
                for: paper,
                temperatureCelsius: toningTemperatureCelsius,
                chemicalManufacturer: toner.manufacturer
            )
            .recommended
    }

    private var waitsForVisualToningContinue: Bool {
        isToningManualContinue && (tonerDilution?.timeRules.isEmpty ?? true)
    }

    private var datasheetWashAfterToningDuration: TimeInterval {
        tonerDilution?.postToningWashDuration(
            for: paper,
            waterTemperatureCelsius: washTemperatureCelsius
        ) ?? paper.washDuration(for: washTemperatureCelsius)
    }

    private func duration(for phase: ProcessPhase, defaultDuration: TimeInterval) -> TimeInterval {
        phaseDurationOverrides[phase] ?? defaultDuration
    }
}
