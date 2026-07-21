import Foundation

public enum PaperType: String, CaseIterable, Codable, Hashable, Identifiable {
    case resinCoated = "RC"
    case fiberBased = "FB"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .resinCoated:
            return "Resin Coated"
        case .fiberBased:
            return "Fiber Based / Baryta"
        }
    }
}

public struct Paper: Identifiable, Codable, Hashable {
    public let id: String
    public let manufacturer: String
    public let name: String
    public let type: PaperType
    public let availableSizes: [PaperSize]
    public let washRules: [WashRule]
    public let developerTemperatureCurve: [TemperatureTimeFactor]

    public var displayName: String {
        "\(manufacturer) \(name) (\(type.rawValue))"
    }

    public init(
        id: String,
        manufacturer: String,
        name: String,
        type: PaperType,
        availableSizes: [PaperSize],
        washRules: [WashRule],
        developerTemperatureCurve: [TemperatureTimeFactor]
    ) {
        self.id = id
        self.manufacturer = manufacturer
        self.name = name
        self.type = type
        self.availableSizes = availableSizes
        self.washRules = washRules
        self.developerTemperatureCurve = developerTemperatureCurve
    }

    public func washDuration(for waterTemperatureCelsius: Double) -> TimeInterval {
        washRules
            .first { $0.matches(temperatureCelsius: waterTemperatureCelsius) }?
            .duration ?? 0
    }

    public func developerTemperatureFactor(for temperatureCelsius: Double) -> Double {
        guard let first = developerTemperatureCurve.first else { return 1 }

        let sortedCurve = developerTemperatureCurve.sorted { $0.temperatureCelsius < $1.temperatureCelsius }

        if temperatureCelsius <= first.temperatureCelsius {
            let temperatureDelta = first.temperatureCelsius - temperatureCelsius
            return first.factor * pow(1.08, temperatureDelta)
        }

        guard let upper = sortedCurve.first(where: { $0.temperatureCelsius >= temperatureCelsius }) else {
            return sortedCurve.last?.factor ?? 1
        }

        guard let lower = sortedCurve.last(where: { $0.temperatureCelsius <= temperatureCelsius }),
              lower.temperatureCelsius != upper.temperatureCelsius else {
            return upper.factor
        }

        let progress = (temperatureCelsius - lower.temperatureCelsius) / (upper.temperatureCelsius - lower.temperatureCelsius)
        return lower.factor + ((upper.factor - lower.factor) * progress)
    }
}

public struct PaperSize: Identifiable, Codable, Hashable {
    public let widthCentimeters: Double
    public let heightCentimeters: Double

    public var id: String {
        "\(widthCentimeters)x\(heightCentimeters)"
    }

    public var displayName: String {
        "\(formatted(widthCentimeters)) x \(formatted(heightCentimeters)) cm"
    }

    public var areaSquareMeters: Double {
        (widthCentimeters / 100) * (heightCentimeters / 100)
    }

    public init(widthCentimeters: Double, heightCentimeters: Double) {
        self.widthCentimeters = widthCentimeters
        self.heightCentimeters = heightCentimeters
    }

    private func formatted(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...1)))
    }
}

public struct WashRule: Codable, Hashable {
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

public struct TemperatureTimeFactor: Codable, Hashable {
    public let temperatureCelsius: Double
    public let factor: Double

    public init(temperatureCelsius: Double, factor: Double) {
        self.temperatureCelsius = temperatureCelsius
        self.factor = factor
    }
}

public enum ProcessPhase: String, CaseIterable, Codable, Hashable, Identifiable {
    case developer
    case transferToStopBath
    case stopBath
    case transferToFixer
    case fixer
    case transferToWash
    case wash

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .developer:
            return "Developer"
        case .transferToStopBath:
            return "Transfer to Stop Bath"
        case .stopBath:
            return "Stop Bath"
        case .transferToFixer:
            return "Transfer to Fixer"
        case .fixer:
            return "Fixer"
        case .transferToWash:
            return "Transfer to Wash"
        case .wash:
            return "Wash"
        }
    }
}

public enum ChemicalRole: String, Codable, Hashable {
    case developer
    case stopBath
    case fixer

    public var phase: ProcessPhase {
        switch self {
        case .developer:
            return .developer
        case .stopBath:
            return .stopBath
        case .fixer:
            return .fixer
        }
    }
}

public struct ChemicalDilution: Identifiable, Codable, Hashable {
    public let ratio: String
    public let timeRules: [ProcessingTimeRule]
    public let capacityRules: [ChemicalCapacityRule]

    public var id: String { ratio }

    public init(
        ratio: String,
        timeRules: [ProcessingTimeRule] = [],
        capacityRules: [ChemicalCapacityRule] = []
    ) {
        self.ratio = ratio
        self.timeRules = timeRules
        self.capacityRules = capacityRules
    }

    public func availableTemperatures(for paper: Paper) -> [Double] {
        let temperatures = matchingRules(for: paper).map(\.temperatureCelsius)
        let uniqueTemperatures = Array(Set(temperatures)).sorted()

        guard let minimum = uniqueTemperatures.first,
              let maximum = uniqueTemperatures.last,
              minimum != maximum else {
            return uniqueTemperatures
        }

        return Array(Int(minimum.rounded())...Int(maximum.rounded())).map(Double.init)
    }

    public func timeRange(for paper: Paper, temperatureCelsius: Double) -> TimeRange {
        let rules = matchingRules(for: paper).sorted { $0.temperatureCelsius < $1.temperatureCelsius }

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

    public func capacityPercent(
        for paper: Paper,
        paperSize: PaperSize,
        completedCycles: Int,
        workingSolutionLiters: Double
    ) -> Int? {
        guard let rule = capacityRule(for: paper) else {
            return nil
        }

        let capacityArea = rule.squareMetersPerLiter * workingSolutionLiters
        guard capacityArea > 0 else { return nil }

        let usedArea = paperSize.areaSquareMeters * Double(completedCycles)
        let remainingRatio = max(0, 1 - (usedArea / capacityArea))
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

    private func capacityRule(for paper: Paper) -> ChemicalCapacityRule? {
        capacityRules.first { $0.paperType == paper.type }
    }

    private func matchingRules(for paper: Paper) -> [ProcessingTimeRule] {
        let exactRules = timeRules.filter { $0.paperID == paper.id }

        if !exactRules.isEmpty {
            return exactRules
        }

        let typeRules = timeRules.filter { $0.paperType == paper.type }

        if !typeRules.isEmpty {
            return typeRules
        }

        return timeRules
    }
}

public struct DilutionMix: Codable, Hashable {
    public let chemicalMilliliters: Int
    public let waterMilliliters: Int
}

public struct ChemicalCapacityRule: Codable, Hashable {
    public let paperType: PaperType
    public let squareMetersPerLiter: Double

    public init(paperType: PaperType, squareMetersPerLiter: Double) {
        self.paperType = paperType
        self.squareMetersPerLiter = squareMetersPerLiter
    }
}

public struct ProcessingTimeRule: Codable, Hashable {
    public let paperID: String?
    public let paperType: PaperType?
    public let temperatureCelsius: Double
    public let timeRange: TimeRange

    public init(
        paperID: String? = nil,
        paperType: PaperType? = nil,
        temperatureCelsius: Double,
        timeRange: TimeRange
    ) {
        self.paperID = paperID
        self.paperType = paperType
        self.temperatureCelsius = temperatureCelsius
        self.timeRange = timeRange
    }
}

public struct TimeRange: Codable, Hashable {
    public let minimum: TimeInterval
    public let maximum: TimeInterval

    public var recommended: TimeInterval {
        ((minimum + maximum) / 2).rounded()
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

        if totalSeconds >= 60, totalSeconds % 60 == 0 {
            return "\(totalSeconds / 60) min"
        }

        return "\(totalSeconds) s"
    }
}

public struct Chemical: Identifiable, Codable, Hashable {
    public let id: String
    public let manufacturer: String
    public let name: String
    public let role: ChemicalRole
    public let dilutions: [ChemicalDilution]

    public var displayName: String {
        "\(manufacturer) \(name)"
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

public struct TimedProcessPhase: Identifiable, Codable, Hashable {
    public let phase: ProcessPhase
    public let duration: TimeInterval

    public var id: ProcessPhase { phase }

    public init(phase: ProcessPhase, duration: TimeInterval) {
        self.phase = phase
        self.duration = duration
    }
}

public struct DevelopmentSession: Identifiable, Codable, Hashable {
    public let id: UUID
    public var paper: Paper
    public var paperSize: PaperSize
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
    public var phaseDurationOverrides: [ProcessPhase: TimeInterval]

    public init(
        id: UUID = UUID(),
        paper: Paper,
        paperSize: PaperSize,
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
        phaseDurationOverrides: [ProcessPhase: TimeInterval] = [:]
    ) {
        self.id = id
        self.paper = paper
        self.paperSize = paperSize
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
        self.phaseDurationOverrides = phaseDurationOverrides
    }

    public func resolvedPhases() -> [TimedProcessPhase] {
        [
            TimedProcessPhase(
                phase: .developer,
                duration: duration(
                    for: .developer,
                    defaultDuration: developerDilution
                        .timeRange(for: paper, temperatureCelsius: developerTemperatureCelsius)
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
                        .timeRange(for: paper, temperatureCelsius: stopBathTemperatureCelsius)
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
                        .timeRange(for: paper, temperatureCelsius: fixerTemperatureCelsius)
                        .recommended
                )
            ),
            TimedProcessPhase(
                phase: .transferToWash,
                duration: duration(for: .transferToWash, defaultDuration: transferAfterFixerDuration)
            ),
            TimedProcessPhase(
                phase: .wash,
                duration: duration(for: .wash, defaultDuration: paper.washDuration(for: fixerTemperatureCelsius))
            )
        ]
    }

    private func duration(for phase: ProcessPhase, defaultDuration: TimeInterval) -> TimeInterval {
        phaseDurationOverrides[phase] ?? defaultDuration
    }
}
