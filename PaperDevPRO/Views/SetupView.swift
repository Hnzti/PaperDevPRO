import SwiftUI

struct SetupView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var usageStore = ChemicalUsageStore.shared
    @ObservedObject private var presetStore = PresetStore.shared
    @ObservedObject private var settingsStore = DarkroomSettingsStore.shared

    let initialSession: DevelopmentSession
    let onResetProject: () -> Void
    let onApply: (DevelopmentSession) -> Void

    @State private var selectedPaper: Paper
    @State private var selectedPaperSize: PaperSize
    @State private var selectedDeveloper: Chemical
    @State private var selectedDeveloperDilution: ChemicalDilution
    @State private var selectedDeveloperTemperature: Double
    @State private var developerVolumeMilliliters: Int
    @State private var selectedStopBath: Chemical
    @State private var selectedStopBathDilution: ChemicalDilution
    @State private var selectedStopBathTemperature: Double
    @State private var stopBathVolumeMilliliters: Int
    @State private var selectedFixer: Chemical
    @State private var selectedFixerDilution: ChemicalDilution
    @State private var selectedFixerTemperature: Double
    @State private var fixerVolumeMilliliters: Int
    @State private var transferAfterDeveloperSeconds: Int
    @State private var transferAfterStopBathSeconds: Int
    @State private var transferAfterFixerSeconds: Int
    @State private var isDeveloperTransferSynced = true
    @State private var isStopBathTransferSynced = true
    @State private var isFixerTransferSynced = true
    @State private var isDeveloperUsageSynced = true
    @State private var isStopBathUsageSynced = true
    @State private var isFixerUsageSynced = true
    @State private var phaseDurationOverrides: [ProcessPhase: Int]
    @State private var activePicker: SetupPicker?
    @State private var isShowingProjectResetConfirmation = false
    @State private var isShowingSettings = false

    private let cardColor = Color(red: 0.08, green: 0.08, blue: 0.08)
    private let dividerColor = Color(red: 1, green: 0, blue: 0).opacity(0.35)

    init(
        initialSession: DevelopmentSession,
        onResetProject: @escaping () -> Void = {},
        onApply: @escaping (DevelopmentSession) -> Void
    ) {
        self.initialSession = initialSession
        self.onResetProject = onResetProject
        self.onApply = onApply
        _selectedPaper = State(initialValue: initialSession.paper)
        _selectedPaperSize = State(initialValue: initialSession.paperSize)
        _selectedDeveloper = State(initialValue: initialSession.developer)
        _selectedDeveloperDilution = State(initialValue: initialSession.developerDilution)
        _selectedDeveloperTemperature = State(initialValue: initialSession.developerTemperatureCelsius)
        _developerVolumeMilliliters = State(initialValue: initialSession.developerVolumeMilliliters)
        _selectedStopBath = State(initialValue: initialSession.stopBath)
        _selectedStopBathDilution = State(initialValue: initialSession.stopBathDilution)
        _selectedStopBathTemperature = State(initialValue: initialSession.stopBathTemperatureCelsius)
        _stopBathVolumeMilliliters = State(initialValue: initialSession.stopBathVolumeMilliliters)
        _selectedFixer = State(initialValue: initialSession.fixer)
        _selectedFixerDilution = State(initialValue: initialSession.fixerDilution)
        _selectedFixerTemperature = State(initialValue: initialSession.fixerTemperatureCelsius)
        _fixerVolumeMilliliters = State(initialValue: initialSession.fixerVolumeMilliliters)
        _transferAfterDeveloperSeconds = State(initialValue: Int(initialSession.transferAfterDeveloperDuration.rounded()))
        _transferAfterStopBathSeconds = State(initialValue: Int(initialSession.transferAfterStopBathDuration.rounded()))
        _transferAfterFixerSeconds = State(initialValue: Int(initialSession.transferAfterFixerDuration.rounded()))
        _phaseDurationOverrides = State(
            initialValue: initialSession.phaseDurationOverrides.mapValues { Int($0.rounded()) }
        )
    }

    var body: some View {
        ZStack {
            DarkroomPalette.black
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    topBar
                    projectResetButton

                    settingsSection(title: "Presety") {
                        pickerRow(
                            title: "Preset",
                            value: presetStore.presets.isEmpty ? "Žádný uložený" : "\(presetStore.presets.count) uložených",
                            picker: .presets
                        )
                    }

                    settingsSection(title: "Papír") {
                        pickerRow(title: "Typ papíru", value: selectedPaper.displayName, picker: .paper)
                        divider
                        pickerRow(title: "Rozměr", value: selectedPaperSize.displayName, picker: .paperSize)
                    }

                    settingsSection(title: "Vývojka") {
                        pickerRow(title: "Chemie", value: selectedDeveloper.displayName, picker: .developer)
                        divider
                        pickerRow(title: "Ředění", value: selectedDeveloperDilution.ratio, picker: .developerDilution)
                        divider
                        pickerRow(title: "Objem", value: millilitersText(developerVolumeMilliliters), picker: .developerVolume)
                        divider
                        mixRows(dilution: selectedDeveloperDilution, totalMilliliters: developerVolumeMilliliters)
                        divider
                        pickerRow(title: "Teplota", value: temperatureText(selectedDeveloperTemperature), picker: .developerTemperature)
                        divider
                        readOnlyRow(title: "Čas", value: selectedDeveloperDilution.timeRange(for: selectedPaper, temperatureCelsius: selectedDeveloperTemperature).displayText)
                        divider
                        capacityRow(chemical: selectedDeveloper, dilution: selectedDeveloperDilution, totalMilliliters: developerVolumeMilliliters)
                        divider
                        usageRow(
                            chemical: selectedDeveloper,
                            dilution: selectedDeveloperDilution,
                            isSynced: isDeveloperUsageSynced
                        ) {
                            toggleUsageSync(for: .developer)
                        } onReset: {
                            resetUsage(for: .developer)
                        }
                        divider
                        transferRow(
                            value: durationText(for: TimeInterval(transferAfterDeveloperSeconds)),
                            picker: .transferAfterDeveloper,
                            isSynced: isDeveloperTransferSynced
                        ) {
                            toggleSync(for: .afterDeveloper)
                        }
                    }

                    settingsSection(title: "Přerušovač") {
                        pickerRow(title: "Chemie", value: selectedStopBath.displayName, picker: .stopBath)
                        divider
                        pickerRow(title: "Ředění", value: selectedStopBathDilution.ratio, picker: .stopBathDilution)
                        divider
                        pickerRow(title: "Objem", value: millilitersText(stopBathVolumeMilliliters), picker: .stopBathVolume)
                        divider
                        mixRows(dilution: selectedStopBathDilution, totalMilliliters: stopBathVolumeMilliliters)
                        divider
                        pickerRow(title: "Teplota", value: temperatureText(selectedStopBathTemperature), picker: .stopBathTemperature)
                        divider
                        readOnlyRow(title: "Čas", value: selectedStopBathDilution.timeRange(for: selectedPaper, temperatureCelsius: selectedStopBathTemperature).displayText)
                        divider
                        capacityRow(chemical: selectedStopBath, dilution: selectedStopBathDilution, totalMilliliters: stopBathVolumeMilliliters)
                        divider
                        usageRow(
                            chemical: selectedStopBath,
                            dilution: selectedStopBathDilution,
                            isSynced: isStopBathUsageSynced
                        ) {
                            toggleUsageSync(for: .stopBath)
                        } onReset: {
                            resetUsage(for: .stopBath)
                        }
                        divider
                        transferRow(
                            value: durationText(for: TimeInterval(transferAfterStopBathSeconds)),
                            picker: .transferAfterStopBath,
                            isSynced: isStopBathTransferSynced
                        ) {
                            toggleSync(for: .afterStopBath)
                        }
                    }

                    settingsSection(title: "Ustalovač") {
                        pickerRow(title: "Chemie", value: selectedFixer.displayName, picker: .fixer)
                        divider
                        pickerRow(title: "Ředění", value: selectedFixerDilution.ratio, picker: .fixerDilution)
                        divider
                        pickerRow(title: "Objem", value: millilitersText(fixerVolumeMilliliters), picker: .fixerVolume)
                        divider
                        mixRows(dilution: selectedFixerDilution, totalMilliliters: fixerVolumeMilliliters)
                        divider
                        pickerRow(title: "Teplota", value: temperatureText(selectedFixerTemperature), picker: .fixerTemperature)
                        divider
                        readOnlyRow(title: "Čas", value: selectedFixerDilution.timeRange(for: selectedPaper, temperatureCelsius: selectedFixerTemperature).displayText)
                        divider
                        capacityRow(chemical: selectedFixer, dilution: selectedFixerDilution, totalMilliliters: fixerVolumeMilliliters)
                        divider
                        usageRow(
                            chemical: selectedFixer,
                            dilution: selectedFixerDilution,
                            isSynced: isFixerUsageSynced
                        ) {
                            toggleUsageSync(for: .fixer)
                        } onReset: {
                            resetUsage(for: .fixer)
                        }
                        divider
                        transferRow(
                            value: durationText(for: TimeInterval(transferAfterFixerSeconds)),
                            picker: .transferAfterFixer,
                            isSynced: isFixerTransferSynced
                        ) {
                            toggleSync(for: .afterFixer)
                        }
                    }

                    settingsSection(title: "Proces") {
                        ForEach(Array(computedSession.resolvedPhases().enumerated()), id: \.element.id) { index, phase in
                            pickerRow(
                                title: displayTitle(for: phase.phase),
                                value: durationText(for: phase.duration),
                                picker: processPicker(for: phase.phase)
                            )

                            if index < computedSession.resolvedPhases().count - 1 {
                                divider
                            }
                        }
                    }

                }
                .padding(20)
            }
        }
        .preferredColorScheme(.dark)
        .statusBar(hidden: true)
        .sheet(item: $activePicker) { picker in
            pickerSheet(for: picker)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsSheetView()
                .interactiveDismissDisabled()
        }
        .confirmationDialog(
            "Opravdu resetovat celý projekt?",
            isPresented: $isShowingProjectResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("RESET PROJEKTU", role: .destructive) {
                onResetProject()
                dismiss()
            }

            Button("ZRUŠIT", role: .cancel) { }
        } message: {
            Text("Smažou se všechny běžící papíry a projekt se vrátí do výchozího stavu.")
        }
    }

    private var topBar: some View {
        HStack {
            circularIconButton(systemName: "chevron.left") {
                applySelection()
            }

            Spacer()

            Text("Setup")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(DarkroomPalette.red)

            Spacer()

            HStack(spacing: 10) {
                resetButton {
                    resetToDefaults()
                }

                circularIconButton(systemName: "gearshape") {
                    isShowingSettings = true
                }
            }
        }
    }

    private var projectResetButton: some View {
        Button {
            isShowingProjectResetConfirmation = true
        } label: {
            Text("RESET PROJEKTU")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(DarkroomPalette.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(DarkroomPalette.red, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }

    private var computedSession: DevelopmentSession {
        DevelopmentSession(
            paper: selectedPaper,
            paperSize: selectedPaperSize,
            developer: selectedDeveloper,
            developerDilution: selectedDeveloperDilution,
            stopBath: selectedStopBath,
            stopBathDilution: selectedStopBathDilution,
            fixer: selectedFixer,
            fixerDilution: selectedFixerDilution,
            developerTemperatureCelsius: selectedDeveloperTemperature,
            stopBathTemperatureCelsius: selectedStopBathTemperature,
            fixerTemperatureCelsius: selectedFixerTemperature,
            developerVolumeMilliliters: developerVolumeMilliliters,
            stopBathVolumeMilliliters: stopBathVolumeMilliliters,
            fixerVolumeMilliliters: fixerVolumeMilliliters,
            transferAfterDeveloperDuration: TimeInterval(transferAfterDeveloperSeconds),
            transferAfterStopBathDuration: TimeInterval(transferAfterStopBathSeconds),
            transferAfterFixerDuration: TimeInterval(transferAfterFixerSeconds),
            phaseDurationOverrides: phaseDurationOverrides.mapValues(TimeInterval.init)
        )
    }

    @ViewBuilder
    private func pickerSheet(for picker: SetupPicker) -> some View {
        switch picker {
        case .presets:
            PresetsSheetView(session: computedSession) { session in
                apply(session: session)
                activePicker = nil
            }
        case .paper:
            selectionSheet(title: "Papír") {
                ForEach(MockDarkroomDatabase.papers) { paper in
                    selectionButton(
                        title: paper.displayName,
                        subtitle: paper.type.displayName,
                        isSelected: paper.id == selectedPaper.id
                    ) {
                        selectedPaper = paper
                        selectedPaperSize = paper.availableSizes.first ?? selectedPaperSize
                        normalizeTemperatures()
                        activePicker = nil
                    }
                }
            }
        case .paperSize:
            selectionSheet(title: "Rozměr") {
                ForEach(selectedPaper.availableSizes) { size in
                    selectionButton(
                        title: size.displayName,
                        subtitle: nil,
                        isSelected: size.id == selectedPaperSize.id
                    ) {
                        selectedPaperSize = size
                        activePicker = nil
                    }
                }
            }
        case .developer:
            selectionSheet(title: "Vývojka") {
                ForEach(MockDarkroomDatabase.developers) { developer in
                    selectionButton(
                        title: developer.displayName,
                        subtitle: developer.dilutions.map(\.ratio).joined(separator: ", "),
                        isSelected: developer.id == selectedDeveloper.id
                    ) {
                        selectedDeveloper = developer
                        selectedDeveloperDilution = developer.dilutions[0]
                        selectedDeveloperTemperature = firstTemperature(for: selectedDeveloperDilution)
                        activePicker = nil
                    }
                }
            }
        case .developerDilution:
            dilutionSheet(
                title: "Ředění vývojky",
                dilutions: selectedDeveloper.dilutions,
                selectedDilution: selectedDeveloperDilution
            ) { dilution in
                selectedDeveloperDilution = dilution
                selectedDeveloperTemperature = firstTemperature(for: dilution)
            }
        case .developerVolume:
            volumePickerSheet(title: "Objem vývojky", milliliters: $developerVolumeMilliliters)
        case .developerTemperature:
            temperatureSheet(
                title: "Teplota vývojky",
                temperatures: availableTemperatures(for: selectedDeveloperDilution),
                selectedTemperature: selectedDeveloperTemperature
            ) { temperature in
                selectedDeveloperTemperature = temperature
            }
        case .stopBath:
            selectionSheet(title: "Přerušovač") {
                ForEach(MockDarkroomDatabase.stopBaths) { stopBath in
                    selectionButton(
                        title: stopBath.displayName,
                        subtitle: stopBath.dilutions.map(\.ratio).joined(separator: ", "),
                        isSelected: stopBath.id == selectedStopBath.id
                    ) {
                        selectedStopBath = stopBath
                        selectedStopBathDilution = stopBath.dilutions[0]
                        selectedStopBathTemperature = firstTemperature(for: selectedStopBathDilution)
                        activePicker = nil
                    }
                }
            }
        case .stopBathDilution:
            dilutionSheet(
                title: "Ředění přerušovače",
                dilutions: selectedStopBath.dilutions,
                selectedDilution: selectedStopBathDilution
            ) { dilution in
                selectedStopBathDilution = dilution
                selectedStopBathTemperature = firstTemperature(for: dilution)
            }
        case .stopBathVolume:
            volumePickerSheet(title: "Objem přerušovače", milliliters: $stopBathVolumeMilliliters)
        case .stopBathTemperature:
            temperatureSheet(
                title: "Teplota přerušovače",
                temperatures: availableTemperatures(for: selectedStopBathDilution),
                selectedTemperature: selectedStopBathTemperature
            ) { temperature in
                selectedStopBathTemperature = temperature
            }
        case .fixer:
            selectionSheet(title: "Ustalovač") {
                ForEach(MockDarkroomDatabase.fixers) { fixer in
                    selectionButton(
                        title: fixer.displayName,
                        subtitle: fixer.dilutions.map(\.ratio).joined(separator: ", "),
                        isSelected: fixer.id == selectedFixer.id
                    ) {
                        selectedFixer = fixer
                        selectedFixerDilution = fixer.dilutions[0]
                        selectedFixerTemperature = firstTemperature(for: selectedFixerDilution)
                        activePicker = nil
                    }
                }
            }
        case .fixerDilution:
            dilutionSheet(
                title: "Ředění ustalovače",
                dilutions: selectedFixer.dilutions,
                selectedDilution: selectedFixerDilution
            ) { dilution in
                selectedFixerDilution = dilution
                selectedFixerTemperature = firstTemperature(for: dilution)
            }
        case .fixerVolume:
            volumePickerSheet(title: "Objem ustalovače", milliliters: $fixerVolumeMilliliters)
        case .fixerTemperature:
            temperatureSheet(
                title: "Teplota ustalovače",
                temperatures: availableTemperatures(for: selectedFixerDilution),
                selectedTemperature: selectedFixerTemperature
            ) { temperature in
                selectedFixerTemperature = temperature
            }
        case .transferAfterDeveloper:
            durationPickerSheet(
                title: "Přendání do přerušovače",
                totalSeconds: transferSecondsBinding(for: .afterDeveloper)
            )
        case .transferAfterStopBath:
            durationPickerSheet(
                title: "Přendání do ustalovače",
                totalSeconds: transferSecondsBinding(for: .afterStopBath)
            )
        case .transferAfterFixer:
            durationPickerSheet(
                title: "Přendání do praní",
                totalSeconds: transferSecondsBinding(for: .afterFixer)
            )
        case .processDeveloperDuration:
            processDurationPickerSheet(title: "Čas vývojky", phase: .developer)
        case .processTransferToStopBathDuration:
            processDurationPickerSheet(title: "Čas přendání do přerušovače", phase: .transferToStopBath)
        case .processStopBathDuration:
            processDurationPickerSheet(title: "Čas přerušovače", phase: .stopBath)
        case .processTransferToFixerDuration:
            processDurationPickerSheet(title: "Čas přendání do ustalovače", phase: .transferToFixer)
        case .processFixerDuration:
            processDurationPickerSheet(title: "Čas ustalovače", phase: .fixer)
        case .processTransferToWashDuration:
            processDurationPickerSheet(title: "Čas přendání do praní", phase: .transferToWash)
        case .processWashDuration:
            processDurationPickerSheet(title: "Čas praní", phase: .wash)
        }
    }

    private func dilutionSheet(
        title: String,
        dilutions: [ChemicalDilution],
        selectedDilution: ChemicalDilution,
        onSelect: @escaping (ChemicalDilution) -> Void
    ) -> some View {
        selectionSheet(title: title) {
            ForEach(dilutions) { dilution in
                selectionButton(
                    title: dilution.ratio,
                    subtitle: dilution.timeRange(for: selectedPaper, temperatureCelsius: firstTemperature(for: dilution)).displayText,
                    isSelected: dilution.id == selectedDilution.id
                ) {
                    onSelect(dilution)
                    activePicker = nil
                }
            }
        }
    }

    private func temperatureSheet(
        title: String,
        temperatures: [Double],
        selectedTemperature: Double,
        onSelect: @escaping (Double) -> Void
    ) -> some View {
        let selectedTemperatureBinding = Binding<Double>(
            get: { selectedTemperature },
            set: { onSelect($0) }
        )

        return ZStack {
            DarkroomPalette.black
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(DarkroomPalette.red)

                Picker("Teplota", selection: selectedTemperatureBinding) {
                    ForEach(temperatures, id: \.self) { temperature in
                        Text(temperatureText(temperature))
                            .foregroundStyle(DarkroomPalette.red)
                            .tag(temperature)
                    }
                }
                .pickerStyle(.wheel)
                .foregroundStyle(DarkroomPalette.red)
                .frame(height: 190)

                confirmationButton
            }
            .padding(22)
        }
        .preferredColorScheme(.dark)
    }

    private func durationPickerSheet(
        title: String,
        totalSeconds: Binding<Int>
    ) -> some View {
        let minutes = Binding<Int>(
            get: { totalSeconds.wrappedValue / 60 },
            set: { totalSeconds.wrappedValue = ($0 * 60) + (totalSeconds.wrappedValue % 60) }
        )
        let seconds = Binding<Int>(
            get: { totalSeconds.wrappedValue % 60 },
            set: { totalSeconds.wrappedValue = ((totalSeconds.wrappedValue / 60) * 60) + $0 }
        )

        return ZStack {
            DarkroomPalette.black
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(DarkroomPalette.red)

                HStack(spacing: 18) {
                    Picker("Minuty", selection: minutes) {
                        ForEach(0...999, id: \.self) { minute in
                            Text("\(minute) min")
                                .foregroundStyle(DarkroomPalette.red)
                        }
                    }
                    .pickerStyle(.wheel)

                    Picker("Sekundy", selection: seconds) {
                        ForEach(0...59, id: \.self) { second in
                            Text("\(second) s")
                                .foregroundStyle(DarkroomPalette.red)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                .foregroundStyle(DarkroomPalette.red)
                .frame(height: 190)

                confirmationButton
            }
            .padding(22)
        }
        .preferredColorScheme(.dark)
    }

    private func volumePickerSheet(title: String, milliliters: Binding<Int>) -> some View {
        ZStack {
            DarkroomPalette.black
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(DarkroomPalette.red)

                Picker("Objem", selection: milliliters) {
                    ForEach(Array(stride(from: 10, through: 10_000, by: 10)), id: \.self) { value in
                        Text(millilitersText(value))
                            .foregroundStyle(DarkroomPalette.red)
                            .tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .foregroundStyle(DarkroomPalette.red)
                .frame(height: 190)

                confirmationButton
            }
            .padding(22)
        }
        .preferredColorScheme(.dark)
    }

    private func processDurationPickerSheet(title: String, phase: ProcessPhase) -> some View {
        durationPickerSheet(
            title: title,
            totalSeconds: Binding<Int>(
                get: {
                    phaseDurationOverrides[phase] ?? baseProcessDurationSeconds(for: phase)
                },
                set: { newValue in
                    phaseDurationOverrides[phase] = newValue
                }
            )
        )
    }

    private var confirmationButton: some View {
        Button {
            activePicker = nil
        } label: {
            Text("BUDIŽ")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(DarkroomPalette.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(RoundedRectangle(cornerRadius: 18).fill(cardColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(DarkroomPalette.red, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }

    private func selectionSheet<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        ZStack {
            DarkroomPalette.black
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(DarkroomPalette.red)
                        .padding(.bottom, 6)

                    content()
                }
                .padding(22)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func selectionButton(
        title: String,
        subtitle: String?,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20, weight: .bold))

                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))

                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 14, weight: .semibold))
                    }
                }

                Spacer()
            }
            .foregroundStyle(DarkroomPalette.red)
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 18).fill(cardColor))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(DarkroomPalette.red.opacity(isSelected ? 1 : 0.25), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func settingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(DarkroomPalette.red)
                .padding(.leading, 18)

            VStack(spacing: 0) {
                content()
            }
            .background(RoundedRectangle(cornerRadius: 24).fill(cardColor))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(DarkroomPalette.red.opacity(0.2), lineWidth: 1)
            )
        }
    }

    private func pickerRow(title: String, value: String, picker: SetupPicker) -> some View {
        Button {
            activePicker = picker
        } label: {
            rowContent(title: title, value: value, showsChevron: true)
        }
        .buttonStyle(.plain)
    }

    private func transferRow(
        value: String,
        picker: SetupPicker,
        isSynced: Bool,
        toggleSync: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 12) {
            Button {
                activePicker = picker
            } label: {
                HStack(spacing: 12) {
                    Text("Přendání")
                        .font(.system(size: 18, weight: .semibold))

                    Spacer(minLength: 16)

                    Text(value)
                        .font(.system(size: 18, weight: .bold))

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .buttonStyle(.plain)

            Button(action: toggleSync) {
                HStack(spacing: 5) {
                    Image(systemName: isSynced ? "checkmark.square.fill" : "square")
                        .font(.system(size: 14, weight: .bold))

                    Text("SYNC")
                        .font(.system(size: 12, weight: .bold))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 7)
                .overlay(
                    Capsule()
                        .stroke(DarkroomPalette.red.opacity(isSynced ? 1 : 0.45), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(DarkroomPalette.red)
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
    }

    private func readOnlyRow(title: String, value: String) -> some View {
        rowContent(title: title, value: value, showsChevron: false)
    }

    @ViewBuilder
    private func mixRows(dilution: ChemicalDilution, totalMilliliters: Int) -> some View {
        let mix = dilution.mixComponents(totalMilliliters: totalMilliliters)
        readOnlyRow(title: "Chemikálie", value: millilitersText(mix.chemicalMilliliters))
        divider
        readOnlyRow(title: "Voda", value: millilitersText(mix.waterMilliliters))
    }

    private func capacityRow(chemical: Chemical, dilution: ChemicalDilution, totalMilliliters: Int) -> some View {
        let percent = dilution.capacityPercent(
            usages: usageStore.entries(for: chemical, dilution: dilution),
            workingSolutionLiters: Double(totalMilliliters) / 1_000
        )

        return readOnlyRow(
            title: "Vydatnost",
            value: percent.map { "\($0) %" } ?? "--"
        )
    }

    private func usageRow(
        chemical: Chemical,
        dilution: ChemicalDilution,
        isSynced: Bool,
        toggleSync: @escaping () -> Void,
        onReset: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 12) {
            Text("Použito")
                .font(.system(size: 18, weight: .semibold))

            Spacer(minLength: 16)

            Text("\(usageStore.count(for: chemical, dilution: dilution))x")
                .font(.system(size: 18, weight: .bold))

            Button(action: onReset) {
                Text("RESET")
                    .font(.system(size: 13, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .overlay(
                        Capsule()
                            .stroke(DarkroomPalette.red, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)

            Button(action: toggleSync) {
                HStack(spacing: 5) {
                    Image(systemName: isSynced ? "checkmark.square.fill" : "square")
                        .font(.system(size: 14, weight: .bold))

                    Text("SYNC")
                        .font(.system(size: 12, weight: .bold))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 7)
                .overlay(
                    Capsule()
                        .stroke(DarkroomPalette.red.opacity(isSynced ? 1 : 0.45), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(DarkroomPalette.red)
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
    }

    private func rowContent(title: String, value: String, showsChevron: Bool) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))

            Spacer(minLength: 16)

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.trailing)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
            }
        }
        .foregroundStyle(DarkroomPalette.red)
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
    }

    private var divider: some View {
        Rectangle()
            .fill(dividerColor)
            .frame(height: 1)
            .padding(.leading, 18)
    }

    private func circularIconButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(DarkroomPalette.red)
                .frame(width: 56, height: 56)
                .background(Circle().fill(cardColor))
                .overlay(Circle().stroke(DarkroomPalette.red.opacity(0.35), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func resetButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text("RESET")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(DarkroomPalette.red)
                .frame(width: 64, height: 56)
                .background(Capsule().fill(cardColor))
                .overlay(Capsule().stroke(DarkroomPalette.red.opacity(0.35), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func availableTemperatures(for dilution: ChemicalDilution) -> [Double] {
        let temperatures = dilution.availableTemperatures(for: selectedPaper)
        return temperatures.isEmpty ? [20] : temperatures
    }

    private func firstTemperature(for dilution: ChemicalDilution) -> Double {
        availableTemperatures(for: dilution).first ?? 20
    }

    private func normalizeTemperatures() {
        selectedDeveloperTemperature = firstTemperature(for: selectedDeveloperDilution)
        selectedStopBathTemperature = firstTemperature(for: selectedStopBathDilution)
        selectedFixerTemperature = firstTemperature(for: selectedFixerDilution)
    }

    private func transferSecondsBinding(for transfer: TransferSyncTarget) -> Binding<Int> {
        Binding<Int>(
            get: { transferSeconds(for: transfer) },
            set: { setTransferSeconds($0, for: transfer) }
        )
    }

    private func transferSeconds(for transfer: TransferSyncTarget) -> Int {
        switch transfer {
        case .afterDeveloper:
            return transferAfterDeveloperSeconds
        case .afterStopBath:
            return transferAfterStopBathSeconds
        case .afterFixer:
            return transferAfterFixerSeconds
        }
    }

    private func setTransferSeconds(_ seconds: Int, for transfer: TransferSyncTarget) {
        switch transfer {
        case .afterDeveloper:
            transferAfterDeveloperSeconds = seconds
        case .afterStopBath:
            transferAfterStopBathSeconds = seconds
        case .afterFixer:
            transferAfterFixerSeconds = seconds
        }

        guard isTransferSynced(transfer) else {
            return
        }

        if isDeveloperTransferSynced {
            transferAfterDeveloperSeconds = seconds
        }

        if isStopBathTransferSynced {
            transferAfterStopBathSeconds = seconds
        }

        if isFixerTransferSynced {
            transferAfterFixerSeconds = seconds
        }
    }

    private func toggleSync(for transfer: TransferSyncTarget) {
        switch transfer {
        case .afterDeveloper:
            isDeveloperTransferSynced.toggle()
        case .afterStopBath:
            isStopBathTransferSynced.toggle()
        case .afterFixer:
            isFixerTransferSynced.toggle()
        }

        guard isTransferSynced(transfer),
              let existingSyncedValue = syncedTransferValue(excluding: transfer) else {
            return
        }

        setTransferSeconds(existingSyncedValue, for: transfer)
    }

    private func isTransferSynced(_ transfer: TransferSyncTarget) -> Bool {
        switch transfer {
        case .afterDeveloper:
            return isDeveloperTransferSynced
        case .afterStopBath:
            return isStopBathTransferSynced
        case .afterFixer:
            return isFixerTransferSynced
        }
    }

    private func syncedTransferValue(excluding transfer: TransferSyncTarget) -> Int? {
        if transfer != .afterDeveloper, isDeveloperTransferSynced {
            return transferAfterDeveloperSeconds
        }

        if transfer != .afterStopBath, isStopBathTransferSynced {
            return transferAfterStopBathSeconds
        }

        if transfer != .afterFixer, isFixerTransferSynced {
            return transferAfterFixerSeconds
        }

        return nil
    }

    private func toggleUsageSync(for target: UsageSyncTarget) {
        switch target {
        case .developer:
            isDeveloperUsageSynced.toggle()
        case .stopBath:
            isStopBathUsageSynced.toggle()
        case .fixer:
            isFixerUsageSynced.toggle()
        }
    }

    private func resetUsage(for target: UsageSyncTarget) {
        guard isUsageSynced(target) else {
            resetUsageChemical(for: target)
            return
        }

        if isDeveloperUsageSynced {
            resetUsageChemical(for: .developer)
        }

        if isStopBathUsageSynced {
            resetUsageChemical(for: .stopBath)
        }

        if isFixerUsageSynced {
            resetUsageChemical(for: .fixer)
        }
    }

    private func resetUsageChemical(for target: UsageSyncTarget) {
        switch target {
        case .developer:
            usageStore.reset(chemical: selectedDeveloper, dilution: selectedDeveloperDilution)
        case .stopBath:
            usageStore.reset(chemical: selectedStopBath, dilution: selectedStopBathDilution)
        case .fixer:
            usageStore.reset(chemical: selectedFixer, dilution: selectedFixerDilution)
        }
    }

    private func isUsageSynced(_ target: UsageSyncTarget) -> Bool {
        switch target {
        case .developer:
            return isDeveloperUsageSynced
        case .stopBath:
            return isStopBathUsageSynced
        case .fixer:
            return isFixerUsageSynced
        }
    }

    private func resetToDefaults() {
        apply(session: MockDarkroomDatabase.configuredDefaultSession)
    }

    private func apply(session: DevelopmentSession) {
        selectedPaper = session.paper
        selectedPaperSize = session.paperSize
        selectedDeveloper = session.developer
        selectedDeveloperDilution = session.developerDilution
        selectedDeveloperTemperature = session.developerTemperatureCelsius
        developerVolumeMilliliters = session.developerVolumeMilliliters
        selectedStopBath = session.stopBath
        selectedStopBathDilution = session.stopBathDilution
        selectedStopBathTemperature = session.stopBathTemperatureCelsius
        stopBathVolumeMilliliters = session.stopBathVolumeMilliliters
        selectedFixer = session.fixer
        selectedFixerDilution = session.fixerDilution
        selectedFixerTemperature = session.fixerTemperatureCelsius
        fixerVolumeMilliliters = session.fixerVolumeMilliliters
        transferAfterDeveloperSeconds = Int(session.transferAfterDeveloperDuration.rounded())
        transferAfterStopBathSeconds = Int(session.transferAfterStopBathDuration.rounded())
        transferAfterFixerSeconds = Int(session.transferAfterFixerDuration.rounded())
        phaseDurationOverrides = session.phaseDurationOverrides.mapValues { Int($0.rounded()) }
    }

    private func baseProcessDurationSeconds(for phase: ProcessPhase) -> Int {
        let baseSession = DevelopmentSession(
            paper: selectedPaper,
            paperSize: selectedPaperSize,
            developer: selectedDeveloper,
            developerDilution: selectedDeveloperDilution,
            stopBath: selectedStopBath,
            stopBathDilution: selectedStopBathDilution,
            fixer: selectedFixer,
            fixerDilution: selectedFixerDilution,
            developerTemperatureCelsius: selectedDeveloperTemperature,
            stopBathTemperatureCelsius: selectedStopBathTemperature,
            fixerTemperatureCelsius: selectedFixerTemperature,
            developerVolumeMilliliters: developerVolumeMilliliters,
            stopBathVolumeMilliliters: stopBathVolumeMilliliters,
            fixerVolumeMilliliters: fixerVolumeMilliliters,
            transferAfterDeveloperDuration: TimeInterval(transferAfterDeveloperSeconds),
            transferAfterStopBathDuration: TimeInterval(transferAfterStopBathSeconds),
            transferAfterFixerDuration: TimeInterval(transferAfterFixerSeconds)
        )

        let duration = baseSession.resolvedPhases().first { $0.phase == phase }?.duration ?? 0
        return Int(duration.rounded())
    }

    private func processPicker(for phase: ProcessPhase) -> SetupPicker {
        switch phase {
        case .developer:
            return .processDeveloperDuration
        case .transferToStopBath:
            return .processTransferToStopBathDuration
        case .stopBath:
            return .processStopBathDuration
        case .transferToFixer:
            return .processTransferToFixerDuration
        case .fixer:
            return .processFixerDuration
        case .transferToWash:
            return .processTransferToWashDuration
        case .wash:
            return .processWashDuration
        }
    }

    private func applySelection() {
        onApply(computedSession)
        dismiss()
    }

    private func temperatureText(_ temperature: Double) -> String {
        settingsStore.formatTemperature(temperature)
    }

    private func millilitersText(_ milliliters: Int) -> String {
        "\(milliliters) ml"
    }

    private func displayTitle(for phase: ProcessPhase) -> String {
        switch phase {
        case .developer:
            return "Vývojka"
        case .stopBath:
            return "Přerušovač"
        case .fixer:
            return "Ustalovač"
        case .transferToStopBath:
            return "Přendání do přerušovače"
        case .transferToFixer:
            return "Přendání do ustalovače"
        case .transferToWash:
            return "Přendání do praní"
        case .wash:
            return "Praní"
        }
    }

    private func durationText(for duration: TimeInterval) -> String {
        let totalSeconds = max(0, Int(duration.rounded()))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

private enum SetupPicker: String, Identifiable {
    case presets
    case paper
    case paperSize
    case developer
    case developerDilution
    case developerVolume
    case developerTemperature
    case stopBath
    case stopBathDilution
    case stopBathVolume
    case stopBathTemperature
    case fixer
    case fixerDilution
    case fixerVolume
    case fixerTemperature
    case transferAfterDeveloper
    case transferAfterStopBath
    case transferAfterFixer
    case processDeveloperDuration
    case processTransferToStopBathDuration
    case processStopBathDuration
    case processTransferToFixerDuration
    case processFixerDuration
    case processTransferToWashDuration
    case processWashDuration

    var id: String { rawValue }
}

private enum TransferSyncTarget {
    case afterDeveloper
    case afterStopBath
    case afterFixer
}

private enum UsageSyncTarget {
    case developer
    case stopBath
    case fixer
}

private struct SettingsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var settingsStore = DarkroomSettingsStore.shared

    private let cardColor = Color(red: 0.08, green: 0.08, blue: 0.08)
    private var copy: AppCopy { settingsStore.copy }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        ZStack {
            DarkroomPalette.black
                .ignoresSafeArea()

            VStack(spacing: 18) {
                settingsTopBar

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        settingsCard {
                            linkRow(title: copy.redDisplay) {
                                SystemSettingsOpener.openColorFilters()
                            }
                            settingsDivider
                            linkRow(title: copy.guidedAccess) {
                                SystemSettingsOpener.openGuidedAccess()
                            }
                        }

                        settingsCard {
                            toggleRow(title: copy.sound, isOn: $settingsStore.isSoundEnabled)
                            settingsDivider
                            toggleRow(title: copy.haptics, isOn: $settingsStore.isHapticsEnabled)
                            settingsDivider
                            toggleRow(title: copy.keepScreenOn, isOn: $settingsStore.keepScreenOn)
                            settingsDivider
                            toggleRow(title: copy.darkroomBrightness, isOn: $settingsStore.isDarkroomBrightnessEnabled)

                            if settingsStore.isDarkroomBrightnessEnabled {
                                settingsDivider
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text(copy.brightnessLevel)
                                            .font(.system(size: 18, weight: .regular))
                                        Spacer()
                                        Text("\(Int((settingsStore.darkroomBrightness * 100).rounded())) %")
                                            .font(.system(size: 18, weight: .bold))
                                    }
                                    Slider(
                                        value: $settingsStore.darkroomBrightness,
                                        in: 0.05...0.6,
                                        step: 0.05
                                    )
                                    .tint(DarkroomPalette.red)
                                }
                                .foregroundStyle(DarkroomPalette.red)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 14)
                            }
                        }

                        settingsCard {
                            stepperRow(
                                title: copy.defaultTransfer,
                                valueText: "\(settingsStore.defaultTransferSeconds) \(copy.secondsSuffix)"
                            ) {
                                settingsStore.defaultTransferSeconds = max(0, settingsStore.defaultTransferSeconds - 1)
                            } onIncrement: {
                                settingsStore.defaultTransferSeconds = min(120, settingsStore.defaultTransferSeconds + 1)
                            }

                            settingsDivider

                            optionRow(
                                title: copy.temperatureUnit,
                                value: settingsStore.temperatureUnit.displayName(language: settingsStore.language)
                            ) {
                                let units = TemperatureUnit.allCases
                                if let index = units.firstIndex(of: settingsStore.temperatureUnit) {
                                    settingsStore.temperatureUnit = units[(index + 1) % units.count]
                                }
                            }

                            settingsDivider

                            optionRow(
                                title: copy.languageTitle,
                                value: settingsStore.language.displayName
                            ) {
                                let languages = AppLanguage.allCases
                                if let index = languages.firstIndex(of: settingsStore.language) {
                                    settingsStore.language = languages[(index + 1) % languages.count]
                                }
                            }
                        }

                        settingsCard {
                            readOnlySettingsRow(title: copy.version, value: appVersion)
                            settingsDivider
                            Text(copy.aboutHint)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(DarkroomPalette.red.opacity(0.85))
                                .padding(.horizontal, 18)
                                .padding(.vertical, 14)
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .preferredColorScheme(.dark)
        .statusBar(hidden: true)
    }

    private var settingsTopBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(DarkroomPalette.red)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(cardColor))
                    .overlay(Circle().stroke(DarkroomPalette.red.opacity(0.35), lineWidth: 1))
            }
            .buttonStyle(.plain)

            Spacer()

            Text(copy.settingsTitle)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(DarkroomPalette.red)

            Spacer()

            Color.clear
                .frame(width: 56, height: 56)
        }
    }

    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(RoundedRectangle(cornerRadius: 24).fill(cardColor))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(DarkroomPalette.red.opacity(0.2), lineWidth: 1)
        )
    }

    private var settingsDivider: some View {
        Rectangle()
            .fill(DarkroomPalette.red.opacity(0.2))
            .frame(height: 1)
            .padding(.leading, 18)
    }

    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(.system(size: 18, weight: isOn.wrappedValue ? .bold : .regular))
        }
        .tint(DarkroomPalette.red)
        .foregroundStyle(DarkroomPalette.red)
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }

    private func linkRow(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))

                Spacer(minLength: 16)

                Text(copy.openSettings)
                    .font(.system(size: 18, weight: .regular))

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(DarkroomPalette.red)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
    }

    private func optionRow(title: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 18, weight: .regular))

                Spacer(minLength: 16)

                Text(value)
                    .font(.system(size: 18, weight: .bold))

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(DarkroomPalette.red)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
    }

    private func stepperRow(
        title: String,
        valueText: String,
        onDecrement: @escaping () -> Void,
        onIncrement: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .regular))

            Spacer(minLength: 12)

            Button(action: onDecrement) {
                Image(systemName: "minus")
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 36, height: 36)
                    .overlay(Circle().stroke(DarkroomPalette.red.opacity(0.45), lineWidth: 1))
            }
            .buttonStyle(.plain)

            Text(valueText)
                .font(.system(size: 18, weight: .bold))
                .frame(minWidth: 48)

            Button(action: onIncrement) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .frame(width: 36, height: 36)
                    .overlay(Circle().stroke(DarkroomPalette.red.opacity(0.45), lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(DarkroomPalette.red)
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }

    private func readOnlySettingsRow(title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .regular))

            Spacer(minLength: 16)

            Text(value)
                .font(.system(size: 18, weight: .bold))
        }
        .foregroundStyle(DarkroomPalette.red)
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
    }
}

private struct PresetsSheetView: View {
    @ObservedObject private var presetStore = PresetStore.shared
    @State private var presetName = ""

    let session: DevelopmentSession
    let onLoad: (DevelopmentSession) -> Void

    private let cardColor = Color(red: 0.08, green: 0.08, blue: 0.08)

    var body: some View {
        ZStack {
            DarkroomPalette.black
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Presety")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(DarkroomPalette.red)

                    savePresetSection

                    if presetStore.presets.isEmpty {
                        Text("Zatím nemáš uložený žádný preset.")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(DarkroomPalette.red)
                            .padding(.top, 10)
                    } else {
                        Text("Načíst preset")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(DarkroomPalette.red)
                            .padding(.top, 8)

                        ForEach(presetStore.presets) { preset in
                            presetRow(preset)
                        }
                    }
                }
                .padding(22)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var savePresetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Uložit aktuální nastavení")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(DarkroomPalette.red)

            TextField("Název presetu", text: $presetName)
                .textInputAutocapitalization(.words)
                .textContentType(.name)
                .autocorrectionDisabled()
                .submitLabel(.done)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(DarkroomPalette.red)
                .tint(DarkroomPalette.red)
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 16).fill(cardColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(DarkroomPalette.red.opacity(0.45), lineWidth: 1)
                )
                .onSubmit {
                    savePreset()
                }

            Button {
                savePreset()
            } label: {
                Text("ULOŽIT PRESET")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(DarkroomPalette.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(RoundedRectangle(cornerRadius: 16).fill(cardColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(DarkroomPalette.red, lineWidth: 2)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private func presetRow(_ preset: DevelopmentPreset) -> some View {
        HStack(spacing: 12) {
            Button {
                onLoad(preset.session)
            } label: {
                VStack(alignment: .leading, spacing: 5) {
                    Text(preset.name)
                        .font(.system(size: 18, weight: .bold))

                    Text(preset.session.paper.displayName)
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(1)
                }
                .foregroundStyle(DarkroomPalette.red)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            Button {
                presetStore.delete(preset)
            } label: {
                Text("SMAZAT")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(DarkroomPalette.red)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .overlay(
                        Capsule()
                            .stroke(DarkroomPalette.red, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 18).fill(cardColor))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(DarkroomPalette.red.opacity(0.25), lineWidth: 1)
        )
    }

    private func savePreset() {
        presetStore.save(name: presetName, session: session)
        presetName = ""
    }
}

#Preview {
    SetupView(initialSession: MockDarkroomDatabase.defaultSession) { _ in }
}
