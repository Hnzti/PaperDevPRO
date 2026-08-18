import Foundation

/// Chemicals, grouped per manufacturer. Times and capacities come from the
/// current manufacturer datasheets; anything derived rather than printed there
/// is flagged with `isEstimated: true` so the UI shows "interpolated" instead of
/// the datasheet seal.
enum ChemicalCatalog {
    static let all: [Chemical] = foma + ilford + kentmere

    // MARK: - Foma (dish/tray, 20 °C)
    static let foma: [Chemical] = [
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
                // proces – přebíráme ruční doby (bezpečně na straně delšího ustálení),
                // proto jsou označené jako odhad.
                ChemicalDilution(
                    ratio: "1+4",
                    timeRules: [
                        ProcessingTimeRule(
                            paperType: .fiberBased,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 180),
                            isEstimated: true
                        ),
                        ProcessingTimeRule(
                            paperType: .resinCoated,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 90),
                            isEstimated: true
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
                // Vydatnost datasheetu: 5 m² z 5 l pracovního roztoku, tj. 1,0 m²/l
                // bez ohledu na podložku – s objemem se tedy škáluje.
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
    ]

    // MARK: - Ilford / HARMAN (dish/tray, 20 °C)
    // Capacities converted from sheets of 8×10" (0.051562 m²) to m²/L.
    static let ilford: [Chemical] = [
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
                        // RC Cooltone: paper developers TDS – „approximately double these
                        // times … to obtain the coolest image colour“.
                        ProcessingTimeRule(
                            paperID: "ilford-multigrade-rc-cooltone",
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 120)
                        )
                    ],
                    capacityRules: [
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 5.2),
                        // „Approximately half these capacities … if only MULTIGRADE RC COOLTONE
                        // is processed“ (delší vyvolávání).
                        ChemicalCapacityRule(
                            paperID: "ilford-multigrade-rc-cooltone",
                            paperType: .resinCoated,
                            squareMetersPerLiter: 2.6
                        ),
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
                        ChemicalCapacityRule(
                            paperID: "ilford-multigrade-rc-cooltone",
                            paperType: .resinCoated,
                            squareMetersPerLiter: 1.8
                        ),
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
                        // „Approximately half these capacities … if only MULTIGRADE RC COOLTONE
                        // is processed“ (delší vyvolávání).
                        ChemicalCapacityRule(
                            paperID: "ilford-multigrade-rc-cooltone",
                            paperType: .resinCoated,
                            squareMetersPerLiter: 1.8
                        ),
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
                        // „Approximately half these capacities … if only MULTIGRADE RC COOLTONE
                        // is processed“ (delší vyvolávání).
                        ChemicalCapacityRule(
                            paperID: "ilford-multigrade-rc-cooltone",
                            paperType: .resinCoated,
                            squareMetersPerLiter: 1.8
                        ),
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
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 2.3)
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
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 4.0),
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 2.0)
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
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 4.0),
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 2.0)
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
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 4.0),
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 2.0)
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
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 4.0),
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 2.0)
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
                        ChemicalCapacityRule(paperType: .resinCoated, squareMetersPerLiter: 4.0),
                        ChemicalCapacityRule(paperType: .fiberBased, squareMetersPerLiter: 2.0)
                    ]
                )
            ]
        ),
    ]

    // MARK: - Kentmere (dish/tray, 20 °C)
    static let kentmere: [Chemical] = [
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
                // Datasheet u 1+4 uvádí jen vydatnost a to, že se čas zkracuje,
                // konkrétní doby ne – proto odhad.
                ChemicalDilution(
                    ratio: "1+4",
                    timeRules: [
                        ProcessingTimeRule(
                            paperType: .resinCoated,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 90),
                            isEstimated: true
                        ),
                        ProcessingTimeRule(
                            paperType: .fiberBased,
                            temperatureCelsius: 20,
                            timeRange: TimeRange(seconds: 180),
                            isEstimated: true
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
}
