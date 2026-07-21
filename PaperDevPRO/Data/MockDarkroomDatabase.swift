import Foundation

public enum MockDarkroomDatabase {
    public static let papers: [Paper] = [
        Paper(
            id: "foma-fomabrom-variant-111",
            manufacturer: "Foma",
            name: "Fomabrom Variant 111",
            type: .fiberBased,
            availableSizes: [
                PaperSize(widthCentimeters: 9, heightCentimeters: 13),
                PaperSize(widthCentimeters: 10, heightCentimeters: 15),
                PaperSize(widthCentimeters: 13, heightCentimeters: 18),
                PaperSize(widthCentimeters: 18, heightCentimeters: 24),
                PaperSize(widthCentimeters: 24, heightCentimeters: 30),
                PaperSize(widthCentimeters: 30, heightCentimeters: 40),
                PaperSize(widthCentimeters: 40, heightCentimeters: 50),
                PaperSize(widthCentimeters: 50, heightCentimeters: 60)
            ],
            washRules: [
                WashRule(maximumTemperatureCelsius: 12, duration: 45 * 60),
                WashRule(minimumTemperatureCelsius: 12, duration: 35 * 60)
            ],
            developerTemperatureCurve: [
                TemperatureTimeFactor(temperatureCelsius: 20, factor: 1),
                TemperatureTimeFactor(temperatureCelsius: 25, factor: 100.0 / 130.0),
                TemperatureTimeFactor(temperatureCelsius: 30, factor: 70.0 / 130.0),
                TemperatureTimeFactor(temperatureCelsius: 35, factor: 45.0 / 130.0)
            ]
        ),
        Paper(
            id: "foma-fomaspeed-variant",
            manufacturer: "Foma",
            name: "Fomaspeed Variant",
            type: .resinCoated,
            availableSizes: [
                PaperSize(widthCentimeters: 9, heightCentimeters: 13),
                PaperSize(widthCentimeters: 10, heightCentimeters: 15),
                PaperSize(widthCentimeters: 13, heightCentimeters: 18),
                PaperSize(widthCentimeters: 18, heightCentimeters: 24),
                PaperSize(widthCentimeters: 24, heightCentimeters: 30),
                PaperSize(widthCentimeters: 30, heightCentimeters: 40),
                PaperSize(widthCentimeters: 40, heightCentimeters: 50),
                PaperSize(widthCentimeters: 50, heightCentimeters: 60)
            ],
            washRules: [
                WashRule(maximumTemperatureCelsius: 12, duration: 4 * 60),
                WashRule(minimumTemperatureCelsius: 12, duration: 2 * 60)
            ],
            developerTemperatureCurve: [
                TemperatureTimeFactor(temperatureCelsius: 20, factor: 1),
                TemperatureTimeFactor(temperatureCelsius: 25, factor: 60.0 / 90.0),
                TemperatureTimeFactor(temperatureCelsius: 30, factor: 40.0 / 90.0),
                TemperatureTimeFactor(temperatureCelsius: 35, factor: 25.0 / 90.0)
            ]
        )
    ]

    public static let chemicals: [Chemical] = [
        Chemical(
            id: "foma-fomatol-lqn",
            manufacturer: "Foma",
            name: "Fomatol LQN",
            role: .developer,
            dilutions: [
                ChemicalDilution(
                    ratio: "1+7",
                    timeRules: [
                        ProcessingTimeRule(
                            paperID: "foma-fomabrom-variant-111",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 100, maximum: 130)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomabrom-variant-111",
                            temperatureCelsius: 25,
                            timeRange: TimeRange(minimum: 70, maximum: 100)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomabrom-variant-111",
                            temperatureCelsius: 30,
                            timeRange: TimeRange(minimum: 50, maximum: 70)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomabrom-variant-111",
                            temperatureCelsius: 35,
                            timeRange: TimeRange(minimum: 30, maximum: 45)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomaspeed-variant",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 60, maximum: 90)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomaspeed-variant",
                            temperatureCelsius: 25,
                            timeRange: TimeRange(minimum: 40, maximum: 60)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomaspeed-variant",
                            temperatureCelsius: 30,
                            timeRange: TimeRange(minimum: 25, maximum: 40)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomaspeed-variant",
                            temperatureCelsius: 35,
                            timeRange: TimeRange(minimum: 15, maximum: 25)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 1.5),
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 3.0)
                    ]
                )
            ]
        ),
        Chemical(
            id: "foma-fomatol-p",
            manufacturer: "Foma",
            name: "Fomatol P",
            role: .developer,
            dilutions: [
                ChemicalDilution(
                    ratio: "stock",
                    timeRules: [
                        ProcessingTimeRule(
                            paperID: "foma-fomabrom-variant-111",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 100, maximum: 130)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomaspeed-variant",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 60, maximum: 90)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 3.75),
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 7.5)
                    ]
                )
            ]
        ),
        Chemical(
            id: "foma-gd-l",
            manufacturer: "Foma",
            name: "GD-L",
            role: .developer,
            dilutions: [
                ChemicalDilution(
                    ratio: "1+2",
                    timeRules: [
                        ProcessingTimeRule(
                            paperID: "foma-fomabrom-variant-111",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 90, maximum: 130)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomaspeed-variant",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 60, maximum: 90)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 2.5),
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 5.0)
                    ]
                )
            ]
        ),
        Chemical(
            id: "foma-univerzalni-vyvojka",
            manufacturer: "Foma",
            name: "Univerzální vývojka",
            role: .developer,
            dilutions: [
                ChemicalDilution(
                    ratio: "stock",
                    timeRules: [
                        ProcessingTimeRule(
                            paperID: "foma-fomabrom-variant-111",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 100, maximum: 130)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomaspeed-variant",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 60, maximum: 90)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 1.5),
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 3.0)
                    ]
                )
            ]
        ),
        Chemical(
            id: "foma-fomacitro",
            manufacturer: "Foma",
            name: "Fomacitro",
            role: .stopBath,
            dilutions: [
                ChemicalDilution(
                    ratio: "1+19",
                    timeRules: [
                        ProcessingTimeRule(
                            paperType: .resinCoated,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 10, maximum: 20)
                        ),
                        ProcessingTimeRule(
                            paperType: .fiberBased,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 20, maximum: 30)
                        )
                    ]
                )
            ]
        ),
        Chemical(
            id: "foma-fomafix",
            manufacturer: "Foma",
            name: "Fomafix",
            role: .fixer,
            dilutions: [
                ChemicalDilution(
                    ratio: "1+5",
                    timeRules: [
                        ProcessingTimeRule(
                            paperID: "foma-fomabrom-variant-111",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 180)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomaspeed-variant",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 90)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 2.0),
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 4.0)
                    ]
                )
            ]
        ),
        Chemical(
            id: "foma-fomafix-p",
            manufacturer: "Foma",
            name: "Fomafix P",
            role: .fixer,
            dilutions: [
                ChemicalDilution(
                    ratio: "working solution",
                    timeRules: [
                        ProcessingTimeRule(
                            paperID: "foma-fomabrom-variant-111",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 300)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomaspeed-variant",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 180)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 1.5),
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 3.0)
                    ]
                )
            ]
        )
    ]

    public static var developers: [Chemical] {
        chemicals.filter { $0.role == .developer }
    }

    public static var stopBaths: [Chemical] {
        chemicals.filter { $0.role == .stopBath }
    }

    public static var fixers: [Chemical] {
        chemicals.filter { $0.role == .fixer }
    }

    public static var defaultSession: DevelopmentSession {
        let paper = papers[0]
        let developer = developers[0]
        let stopBath = stopBaths[0]
        let fixer = fixers[0]

        return DevelopmentSession(
            paper: paper,
            paperSize: paper.availableSizes[3],
            developer: developer,
            developerDilution: developer.dilutions[0],
            stopBath: stopBath,
            stopBathDilution: stopBath.dilutions[0],
            fixer: fixer,
            fixerDilution: fixer.dilutions[0],
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
}
