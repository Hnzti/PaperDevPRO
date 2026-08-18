import Foundation

/// Sheet sizes shared by the whole ILFORD / Kentmere catalog (both metric and
/// inch cuts are sold, so both stay in the list).
enum CatalogSheetSizes {
    static let harmanSheets: [PaperSize] = [
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

/// Papers, grouped per manufacturer so a datasheet update only touches one block.
enum PaperCatalog {
    static let all: [Paper] = foma + ilford + kentmere

    static let foma: [Paper] = [
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
        )
    ]

    static let ilford: [Paper] = [
        Paper(
            id: "ilford-harman-direct-positive-fb",
            manufacturer: "Ilford",
            name: "HARMAN Direct Positive FB",
            type: .fiberBased,
            availableSizes: CatalogSheetSizes.harmanSheets,
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
            availableSizes: CatalogSheetSizes.harmanSheets,
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
            availableSizes: CatalogSheetSizes.harmanSheets,
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
            availableSizes: CatalogSheetSizes.harmanSheets,
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
            availableSizes: CatalogSheetSizes.harmanSheets,
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
            availableSizes: CatalogSheetSizes.harmanSheets,
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
            availableSizes: CatalogSheetSizes.harmanSheets,
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
            availableSizes: CatalogSheetSizes.harmanSheets,
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
            availableSizes: CatalogSheetSizes.harmanSheets,
            washRules: [
                WashRule(minimumTemperatureCelsius: 5, duration: 45 * 60)
            ],
            developerTemperatureCurve: [
                TemperatureTimeFactor(temperatureCelsius: 20, factor: 1)
            ]
        )
    ]

    static let kentmere: [Paper] = [
        Paper(
            id: "kentmere-vc-select",
            manufacturer: "Kentmere",
            name: "VC Select",
            type: .resinCoated,
            availableSizes: CatalogSheetSizes.harmanSheets,
            washRules: [
                WashRule(minimumTemperatureCelsius: 5, duration: 2 * 60)
            ],
            developerTemperatureCurve: [
                TemperatureTimeFactor(temperatureCelsius: 20, factor: 1)
            ]
        )
    ]
}
