import Foundation

private enum IlfordCatalogSizes {
    static let sheets: [PaperSize] = [
        PaperSize(widthCentimeters: 10.2, heightCentimeters: 12.7),
        PaperSize(widthCentimeters: 12.7, heightCentimeters: 17.8),
        PaperSize(widthCentimeters: 13, heightCentimeters: 18),
        PaperSize(widthCentimeters: 18, heightCentimeters: 24),
        PaperSize(widthCentimeters: 20.3, heightCentimeters: 25.4),
        PaperSize(widthCentimeters: 24, heightCentimeters: 30),
        PaperSize(widthCentimeters: 27.9, heightCentimeters: 35.6),
        PaperSize(widthCentimeters: 30.5, heightCentimeters: 40.6),
        PaperSize(widthCentimeters: 40.6, heightCentimeters: 50.8)
    ]
}

public enum MockDarkroomDatabase {
    public static let papers: [Paper] = [
        Paper(
            id: "foma-fomabrom-variant",
            manufacturer: "Foma",
            name: "Fomabrom Variant",
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
        ),
        Paper(
            id: "foma-fomaspeed",
            manufacturer: "Foma",
            name: "Fomaspeed",
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
                TemperatureTimeFactor(temperatureCelsius: 20, factor: 1)
            ]
        ),
        Paper(
            id: "foma-fomabrom",
            manufacturer: "Foma",
            name: "Fomabrom",
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
                WashRule(minimumTemperatureCelsius: 12, duration: 30 * 60)
            ],
            developerTemperatureCurve: [
                TemperatureTimeFactor(temperatureCelsius: 20, factor: 1)
            ]
        ),
        Paper(
            id: "foma-fomabrom-n-chamois",
            manufacturer: "Foma",
            name: "Fomabrom N chamois",
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
                WashRule(minimumTemperatureCelsius: 12, duration: 30 * 60)
            ],
            developerTemperatureCurve: [
                TemperatureTimeFactor(temperatureCelsius: 20, factor: 1)
            ]
        ),
        Paper(
            id: "foma-fomatone-mg-classic",
            manufacturer: "Foma",
            name: "Fomatone MG Classic",
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
                WashRule(minimumTemperatureCelsius: 12, duration: 30 * 60)
            ],
            developerTemperatureCurve: [
                TemperatureTimeFactor(temperatureCelsius: 20, factor: 1)
            ]
        ),
        Paper(
            id: "foma-retrobrom-sp",
            manufacturer: "Foma",
            name: "Retrobrom Sp",
            type: .fiberBased,
            availableSizes: [
                PaperSize(widthCentimeters: 13, heightCentimeters: 18),
                PaperSize(widthCentimeters: 18, heightCentimeters: 24),
                PaperSize(widthCentimeters: 24, heightCentimeters: 30),
                PaperSize(widthCentimeters: 30, heightCentimeters: 40),
                PaperSize(widthCentimeters: 40, heightCentimeters: 50),
                PaperSize(widthCentimeters: 50, heightCentimeters: 60)
            ],
            washRules: [
                WashRule(maximumTemperatureCelsius: 12, duration: 45 * 60),
                WashRule(minimumTemperatureCelsius: 12, duration: 30 * 60)
            ],
            developerTemperatureCurve: [
                TemperatureTimeFactor(temperatureCelsius: 20, factor: 1)
            ]
        ),
        Paper(
            id: "foma-fomapastel-mg",
            manufacturer: "Foma",
            name: "Fomapastel MG",
            type: .fiberBased,
            availableSizes: [
                PaperSize(widthCentimeters: 20.3, heightCentimeters: 25.4),
                PaperSize(widthCentimeters: 30.5, heightCentimeters: 40.6),
                PaperSize(widthCentimeters: 50.8, heightCentimeters: 61)
            ],
            washRules: [
                WashRule(maximumTemperatureCelsius: 12, duration: 45 * 60),
                WashRule(minimumTemperatureCelsius: 12, duration: 35 * 60)
            ],
            developerTemperatureCurve: [
                TemperatureTimeFactor(temperatureCelsius: 18, factor: 1.3),
                TemperatureTimeFactor(temperatureCelsius: 20, factor: 1.0),
                TemperatureTimeFactor(temperatureCelsius: 22, factor: 0.8),
                TemperatureTimeFactor(temperatureCelsius: 24, factor: 0.6)
            ]
        ),
        Paper(
            id: "ilford-harman-direct-positive-fb",
            manufacturer: "Ilford",
            name: "HARMAN Direct Positive FB",
            type: .fiberBased,
            availableSizes: IlfordCatalogSizes.sheets,
            washRules: [
                WashRule(minimumTemperatureCelsius: 5, duration: 60 * 60)
            ],
            developerTemperatureCurve: [
                TemperatureTimeFactor(temperatureCelsius: 20, factor: 1)
            ]
        ),
        Paper(
            id: "ilford-multigrade-rc-deluxe",
            manufacturer: "Ilford",
            name: "MULTIGRADE RC Deluxe",
            type: .resinCoated,
            availableSizes: IlfordCatalogSizes.sheets,
            washRules: [
                WashRule(minimumTemperatureCelsius: 5, duration: 2 * 60)
            ],
            developerTemperatureCurve: [
                TemperatureTimeFactor(temperatureCelsius: 20, factor: 1)
            ]
        ),
        Paper(
            id: "ilford-multigrade-rc-portfolio",
            manufacturer: "Ilford",
            name: "MULTIGRADE RC Portfolio",
            type: .resinCoated,
            availableSizes: IlfordCatalogSizes.sheets,
            washRules: [
                WashRule(minimumTemperatureCelsius: 5, duration: 2 * 60)
            ],
            developerTemperatureCurve: [
                TemperatureTimeFactor(temperatureCelsius: 20, factor: 1)
            ]
        ),
        Paper(
            id: "ilford-multigrade-rc-warmtone",
            manufacturer: "Ilford",
            name: "MULTIGRADE RC Warmtone",
            type: .resinCoated,
            availableSizes: IlfordCatalogSizes.sheets,
            washRules: [
                WashRule(minimumTemperatureCelsius: 5, duration: 2 * 60)
            ],
            developerTemperatureCurve: [
                TemperatureTimeFactor(temperatureCelsius: 20, factor: 1)
            ]
        ),
        Paper(
            id: "ilford-multigrade-rc-cooltone",
            manufacturer: "Ilford",
            name: "MULTIGRADE RC Cooltone",
            type: .resinCoated,
            availableSizes: IlfordCatalogSizes.sheets,
            washRules: [
                WashRule(minimumTemperatureCelsius: 5, duration: 2 * 60)
            ],
            developerTemperatureCurve: [
                TemperatureTimeFactor(temperatureCelsius: 20, factor: 1)
            ]
        ),
        Paper(
            id: "ilford-multigrade-fb-classic",
            manufacturer: "Ilford",
            name: "MULTIGRADE FB Classic",
            type: .fiberBased,
            availableSizes: IlfordCatalogSizes.sheets,
            washRules: [
                WashRule(minimumTemperatureCelsius: 5, duration: 45 * 60)
            ],
            developerTemperatureCurve: [
                TemperatureTimeFactor(temperatureCelsius: 20, factor: 1)
            ]
        ),
        Paper(
            id: "ilford-multigrade-fb-cooltone",
            manufacturer: "Ilford",
            name: "MULTIGRADE FB Cooltone",
            type: .fiberBased,
            availableSizes: IlfordCatalogSizes.sheets,
            washRules: [
                WashRule(minimumTemperatureCelsius: 5, duration: 60 * 60)
            ],
            developerTemperatureCurve: [
                TemperatureTimeFactor(temperatureCelsius: 20, factor: 1)
            ]
        ),
        Paper(
            id: "ilford-multigrade-fb-warmtone",
            manufacturer: "Ilford",
            name: "MULTIGRADE FB Warmtone",
            type: .fiberBased,
            availableSizes: IlfordCatalogSizes.sheets,
            washRules: [
                WashRule(minimumTemperatureCelsius: 5, duration: 60 * 60)
            ],
            developerTemperatureCurve: [
                TemperatureTimeFactor(temperatureCelsius: 20, factor: 1)
            ]
        ),
        Paper(
            id: "ilford-multigrade-art-300",
            manufacturer: "Ilford",
            name: "MULTIGRADE ART 300",
            type: .fiberBased,
            availableSizes: IlfordCatalogSizes.sheets,
            washRules: [
                WashRule(minimumTemperatureCelsius: 5, duration: 45 * 60)
            ],
            developerTemperatureCurve: [
                TemperatureTimeFactor(temperatureCelsius: 20, factor: 1)
            ]
        ),
        Paper(
            id: "kentmere-vc-select",
            manufacturer: "Kentmere",
            name: "VC Select",
            type: .resinCoated,
            availableSizes: IlfordCatalogSizes.sheets,
            washRules: [
                WashRule(minimumTemperatureCelsius: 5, duration: 2 * 60)
            ],
            developerTemperatureCurve: [
                TemperatureTimeFactor(temperatureCelsius: 20, factor: 1)
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
                            paperID: "foma-fomabrom-variant",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 100, maximum: 130)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomabrom-variant",
                            temperatureCelsius: 25,
                            timeRange: TimeRange(minimum: 70, maximum: 100)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomabrom-variant",
                            temperatureCelsius: 30,
                            timeRange: TimeRange(minimum: 50, maximum: 70)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomabrom-variant",
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
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomaspeed",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 60, maximum: 90)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomabrom",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 90, maximum: 120)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomabrom-n-chamois",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 60, maximum: 100)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomatone-mg-classic",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 90, maximum: 180)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-retrobrom-sp",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 120, maximum: 240)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomapastel-mg",
                            temperatureCelsius: 18,
                            timeRange: TimeRange(minimum: 52, maximum: 78)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomapastel-mg",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 40, maximum: 60)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomapastel-mg",
                            temperatureCelsius: 22,
                            timeRange: TimeRange(minimum: 32, maximum: 48)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomapastel-mg",
                            temperatureCelsius: 24,
                            timeRange: TimeRange(minimum: 24, maximum: 36)
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
                            paperID: "foma-fomabrom-variant",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 100, maximum: 130)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomaspeed-variant",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 60, maximum: 90)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomabrom",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 90, maximum: 120)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomaspeed",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 60, maximum: 90)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomatone-mg-classic",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 90, maximum: 180)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-retrobrom-sp",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 120, maximum: 240)
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
                            paperID: "foma-fomabrom-variant",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 90, maximum: 130)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomaspeed-variant",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 60, maximum: 90)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomabrom",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 90, maximum: 130)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomaspeed",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 60, maximum: 90)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomatone-mg-classic",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 90, maximum: 180)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-retrobrom-sp",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 90, maximum: 180)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 2.5),
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 5.0)
                    ]
                ),
                ChemicalDilution(
                    ratio: "1+3",
                    timeRules: [
                        ProcessingTimeRule(
                            paperID: "foma-fomapastel-mg",
                            temperatureCelsius: 18,
                            timeRange: TimeRange(minimum: 65, maximum: 104)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomapastel-mg",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 50, maximum: 80)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomapastel-mg",
                            temperatureCelsius: 22,
                            timeRange: TimeRange(minimum: 40, maximum: 64)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomapastel-mg",
                            temperatureCelsius: 24,
                            timeRange: TimeRange(minimum: 30, maximum: 48)
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
                            paperID: "foma-fomabrom-variant",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 100, maximum: 130)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomaspeed-variant",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 60, maximum: 90)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomabrom",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 90, maximum: 120)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomaspeed",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 60, maximum: 90)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomatone-mg-classic",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 90, maximum: 180)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-retrobrom-sp",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 120, maximum: 240)
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
            id: "foma-fomatol-pw",
            manufacturer: "Foma",
            name: "Fomatol PW",
            role: .developer,
            dilutions: [
                ChemicalDilution(
                    ratio: "1+0",
                    timeRules: [
                        ProcessingTimeRule(
                            paperID: "foma-fomabrom",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 180, maximum: 240)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomabrom-variant",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 180, maximum: 240)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomaspeed",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 120, maximum: 180)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomaspeed-variant",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 120, maximum: 180)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomatone-mg-classic",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 120, maximum: 180)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-retrobrom-sp",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 120, maximum: 240)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 1.5)
                    ]
                ),
                ChemicalDilution(
                    ratio: "1+1",
                    timeRules: [
                        ProcessingTimeRule(
                            paperID: "foma-fomatone-mg-classic",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 240, maximum: 360)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-retrobrom-sp",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 300, maximum: 420)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 1.5)
                    ]
                ),
                ChemicalDilution(
                    ratio: "1+3",
                    timeRules: [
                        ProcessingTimeRule(
                            paperID: "foma-fomatone-mg-classic",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 480, maximum: 720)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-retrobrom-sp",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 540, maximum: 840)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 1.5)
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
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomatone-mg-classic",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 10, maximum: 20)
                        ),
                        ProcessingTimeRule(
                            paperID: "foma-fomapastel-mg",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 7, maximum: 10)
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
                // Ruční zpracování 1+5. Datasheet uvádí časy jen podle typu podložky
                // (baryt 3 min, RC 1,5 min při 20 °C) – platí pro všechny papíry v tabulce.
                ChemicalDilution(
                    ratio: "1+5",
                    timeRules: [
                        ProcessingTimeRule(
                            paperType: .fiberBased,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 180)
                        ),
                        ProcessingTimeRule(
                            paperType: .resinCoated,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 90)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 2.0),
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 4.0)
                    ]
                ),
                // Strojní zpracování 1+4. Datasheet neuvádí zvlášť časy pro strojní
                // proces – přebíráme ruční doby (bezpečně na straně delšího ustálení).
                ChemicalDilution(
                    ratio: "1+4",
                    timeRules: [
                        ProcessingTimeRule(
                            paperType: .fiberBased,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 180)
                        ),
                        ProcessingTimeRule(
                            paperType: .resinCoated,
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
                // Práškový ustalovač, jen ruční zpracování. Časy podle typu podložky
                // (baryt 5 min, RC 3 min při 20 °C).
                ChemicalDilution(
                    ratio: "working solution",
                    timeRules: [
                        ProcessingTimeRule(
                            paperType: .fiberBased,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 300)
                        ),
                        ProcessingTimeRule(
                            paperType: .resinCoated,
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
        ),
        Chemical(
            id: "foma-fomatoner-sepia",
            manufacturer: "Foma",
            name: "Fomatoner Sepia",
            role: .toner,
            dilutions: [
                // Dvoulázňový sulfidický tónovač (bělící roztok A + tónovací roztok B),
                // obě složky se ředí 1+9. Doba tónování se řídí opticky (dokud nejsou
                // vytónovány i nejtmavší partie), proto nemá pevný čas z datasheetu.
                // Vydatnost: cca 5 m² z jedné soupravy bez ohledu na podložku.
                ChemicalDilution(
                    ratio: "1+9",
                    timeRules: [],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 1.0),
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 1.0)
                    ]
                )
            ]
        ),

        // MARK: - Ilford / HARMAN (dish/tray, 20 °C)
        // Kapacity přepočtené z 8×10" (0,051562 m²) na m²/L.

        Chemical(
            id: "ilford-multigrade",
            manufacturer: "Ilford",
            name: "MULTIGRADE",
            role: .developer,
            dilutions: [
                ChemicalDilution(
                    ratio: "1+9",
                    timeRules: [
                        ProcessingTimeRule(
                            paperType: .resinCoated,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 60)
                        ),
                        ProcessingTimeRule(
                            paperType: .fiberBased,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 90, maximum: 180)
                        ),
                        ProcessingTimeRule(
                            paperID: "ilford-harman-direct-positive-fb",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 90, maximum: 180)
                        ),
                        // RC Cooltone – cca 2× čas pro nejchladnější tón (developers TDS)
                        ProcessingTimeRule(
                            paperID: "ilford-multigrade-rc-cooltone",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 120)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 5.2),
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 2.6)
                    ]
                ),
                ChemicalDilution(
                    ratio: "1+14",
                    timeRules: [
                        ProcessingTimeRule(
                            paperType: .resinCoated,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 90)
                        ),
                        ProcessingTimeRule(
                            paperType: .fiberBased,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 120, maximum: 300)
                        ),
                        ProcessingTimeRule(
                            paperID: "ilford-harman-direct-positive-fb",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 120, maximum: 300)
                        ),
                        ProcessingTimeRule(
                            paperID: "ilford-multigrade-rc-cooltone",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 180)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 3.6),
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 2.1)
                    ]
                )
            ]
        ),
        Chemical(
            id: "ilford-pq-universal",
            manufacturer: "Ilford",
            name: "PQ UNIVERSAL",
            role: .developer,
            dilutions: [
                ChemicalDilution(
                    ratio: "1+9",
                    timeRules: [
                        ProcessingTimeRule(
                            paperType: .resinCoated,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 120)
                        ),
                        ProcessingTimeRule(
                            paperType: .fiberBased,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 90, maximum: 180)
                        ),
                        ProcessingTimeRule(
                            paperID: "ilford-harman-direct-positive-fb",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 90, maximum: 180)
                        ),
                        ProcessingTimeRule(
                            paperID: "ilford-multigrade-rc-cooltone",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 240)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 3.6),
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 2.3)
                    ]
                )
            ]
        ),
        Chemical(
            id: "ilford-bromophen",
            manufacturer: "Ilford",
            name: "BROMOPHEN",
            role: .developer,
            dilutions: [
                ChemicalDilution(
                    ratio: "1+3",
                    timeRules: [
                        ProcessingTimeRule(
                            paperType: .resinCoated,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 120)
                        ),
                        ProcessingTimeRule(
                            paperType: .fiberBased,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 90, maximum: 180)
                        ),
                        ProcessingTimeRule(
                            paperID: "ilford-multigrade-rc-cooltone",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 240)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 3.6),
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 2.3)
                    ]
                )
            ]
        ),
        Chemical(
            id: "ilford-harman-warmtone",
            manufacturer: "Ilford",
            name: "HARMAN WARMTONE",
            role: .developer,
            dilutions: [
                ChemicalDilution(
                    ratio: "1+9",
                    timeRules: [
                        ProcessingTimeRule(
                            paperType: .fiberBased,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 90, maximum: 180)
                        ),
                        ProcessingTimeRule(
                            paperID: "ilford-multigrade-fb-warmtone",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(minimum: 90, maximum: 180)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 2.6)
                    ]
                )
            ]
        ),
        Chemical(
            id: "ilford-ilfostop",
            manufacturer: "Ilford",
            name: "ILFOSTOP",
            role: .stopBath,
            dilutions: [
                ChemicalDilution(
                    ratio: "1+19",
                    timeRules: [
                        ProcessingTimeRule(
                            paperType: .resinCoated,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 10)
                        ),
                        ProcessingTimeRule(
                            paperType: .fiberBased,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 10)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 3.1),
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 1.5)
                    ]
                )
            ]
        ),
        Chemical(
            id: "ilford-ilfostop-pro",
            manufacturer: "Ilford",
            name: "ILFOSTOP PRO",
            role: .stopBath,
            dilutions: [
                ChemicalDilution(
                    ratio: "1+19",
                    timeRules: [
                        ProcessingTimeRule(
                            paperType: .resinCoated,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 10)
                        ),
                        ProcessingTimeRule(
                            paperType: .fiberBased,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 10)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 4.6),
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 4.6)
                    ]
                )
            ]
        ),
        Chemical(
            id: "ilford-rapid-fixer",
            manufacturer: "Ilford",
            name: "Rapid Fixer",
            role: .fixer,
            dilutions: [
                ChemicalDilution(
                    ratio: "1+4",
                    timeRules: [
                        ProcessingTimeRule(
                            paperType: .resinCoated,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 30)
                        ),
                        ProcessingTimeRule(
                            paperType: .fiberBased,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 60)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 4.1),
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 2.1)
                    ]
                ),
                ChemicalDilution(
                    ratio: "1+9",
                    timeRules: [
                        ProcessingTimeRule(
                            paperType: .resinCoated,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 60)
                        ),
                        ProcessingTimeRule(
                            paperType: .fiberBased,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 120)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 4.1),
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 2.1)
                    ]
                )
            ]
        ),
        Chemical(
            id: "ilford-hypam",
            manufacturer: "Ilford",
            name: "Hypam",
            role: .fixer,
            dilutions: [
                ChemicalDilution(
                    ratio: "1+4",
                    timeRules: [
                        ProcessingTimeRule(
                            paperType: .resinCoated,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 30)
                        ),
                        ProcessingTimeRule(
                            paperType: .fiberBased,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 60)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 4.1),
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 2.1)
                    ]
                ),
                ChemicalDilution(
                    ratio: "1+9",
                    timeRules: [
                        ProcessingTimeRule(
                            paperType: .resinCoated,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 60)
                        ),
                        ProcessingTimeRule(
                            paperType: .fiberBased,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 120)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 4.1),
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 2.1)
                    ]
                )
            ]
        ),
        Chemical(
            id: "ilford-ilfofix-ii",
            manufacturer: "Ilford",
            name: "ILFOFIX II",
            role: .fixer,
            dilutions: [
                ChemicalDilution(
                    ratio: "stock",
                    timeRules: [
                        ProcessingTimeRule(
                            paperType: .resinCoated,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 120)
                        ),
                        ProcessingTimeRule(
                            paperType: .fiberBased,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 180)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 4.1),
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 2.1)
                    ]
                )
            ]
        ),

        // MARK: - Kentmere (dish/tray, 20 °C)
        Chemical(
            id: "kentmere-paper-developer",
            manufacturer: "Kentmere",
            name: "Paper Developer",
            role: .developer,
            dilutions: [
                ChemicalDilution(
                    ratio: "1+9",
                    timeRules: [
                        ProcessingTimeRule(
                            paperType: .resinCoated,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 90)
                        ),
                        ProcessingTimeRule(
                            paperType: .fiberBased,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 120)
                        )
                    ],
                    capacityRules: [
                        // 100–150 / 75–100 × 8×10 → střed
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 6.4),
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 4.5)
                    ]
                )
            ]
        ),
        Chemical(
            id: "kentmere-stop-bath",
            manufacturer: "Kentmere",
            name: "Stop Bath",
            role: .stopBath,
            dilutions: [
                ChemicalDilution(
                    ratio: "1+9",
                    timeRules: [
                        ProcessingTimeRule(
                            paperType: .resinCoated,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 20)
                        ),
                        ProcessingTimeRule(
                            paperType: .fiberBased,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 30)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 7.7),
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 7.7)
                    ]
                )
            ]
        ),
        Chemical(
            id: "kentmere-fixer",
            manufacturer: "Kentmere",
            name: "Fixer",
            role: .fixer,
            dilutions: [
                ChemicalDilution(
                    ratio: "1+9",
                    timeRules: [
                        ProcessingTimeRule(
                            paperType: .resinCoated,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 120)
                        ),
                        ProcessingTimeRule(
                            paperType: .fiberBased,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 300)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 3.5),
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 1.8)
                    ]
                ),
                ChemicalDilution(
                    ratio: "1+4",
                    timeRules: [
                        ProcessingTimeRule(
                            paperType: .resinCoated,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 90)
                        ),
                        ProcessingTimeRule(
                            paperType: .fiberBased,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 180)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 4.5),
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 2.1)
                    ]
                )
            ]
        )
    ]

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
