import SwiftUI

struct SetupView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var usageStore = ChemicalUsageStore.shared
    @ObservedObject private var presetStore = PresetStore.shared
    @ObservedObject private var settingsStore = DarkroomSettingsStore.shared

    let initialSession: DevelopmentSession
    /// The selected sheet already ran to the end – editing it rewrites a finished record.
    let isEditingFinishedRun: Bool
    let onResetProject: () -> Void
    let onOpenSettings: () -> Void
    let onBack: (() -> Void)?
    let onApply: (DevelopmentSession) -> Void

    @State private var selectedPaper: Paper
    @State private var selectedPaperSize: PaperSize
    @State private var selectedTestStripPaper: Paper
    @State private var selectedTestStripPaperSize: PaperSize
    @State private var customWidthCentimeters: Double = 2.5
    @State private var customHeightCentimeters: Double = 10
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
    @State private var washTemperature: Double
    @State private var isToningEnabled: Bool
    @State private var selectedToner: Chemical
    @State private var selectedTonerDilution: ChemicalDilution
    @State private var selectedTonerTemperature: Double
    @State private var tonerVolumeMilliliters: Int
    @State private var toningSeconds: Int
    @State private var isTonerUsageSynced = true
    @State private var isDeveloperTransferSynced = true
    @State private var isStopBathTransferSynced = true
    @State private var isFixerTransferSynced = true
    @State private var isDeveloperUsageSynced = true
    @State private var isStopBathUsageSynced = true
    @State private var isFixerUsageSynced = true
    @State private var phaseDurationOverrides: [ProcessPhase: Int]
    /// Stable identity for `computedSession`. A fresh `UUID()` per evaluation made the
    /// session compare unequal on every redraw, which broke `ForEach` and change tracking.
    @State private var sessionID: UUID
    @State private var activePicker: SetupPicker?
    @State private var pickerBrandFilter: String = "Foma"
    @State private var pendingReset: ResetKind?
    @State private var isNavigatingToSettings = false
    @State private var isResettingProject = false

    private enum ResetKind {
        case project
        case setup
    }

    private let cardColor = DarkroomPalette.black
    private let dividerColor = Color(red: 1, green: 0, blue: 0).opacity(0.35)
    private var copy: AppCopy { settingsStore.copy }

    init(
        initialSession: DevelopmentSession,
        isEditingFinishedRun: Bool = false,
        onResetProject: @escaping () -> Void = {},
        onOpenSettings: @escaping () -> Void = {},
        onBack: (() -> Void)? = nil,
        onApply: @escaping (DevelopmentSession) -> Void
    ) {
        self.initialSession = initialSession
        self.isEditingFinishedRun = isEditingFinishedRun
        self.onResetProject = onResetProject
        self.onOpenSettings = onOpenSettings
        self.onBack = onBack
        self.onApply = onApply
        _selectedPaper = State(initialValue: initialSession.paper)
        _selectedPaperSize = State(initialValue: initialSession.paperSize)
        _selectedTestStripPaper = State(initialValue: initialSession.testStripPaper)
        _selectedTestStripPaperSize = State(initialValue: initialSession.testStripPaperSize)
        _customWidthCentimeters = State(initialValue: initialSession.testStripPaperSize.widthCentimeters)
        _customHeightCentimeters = State(initialValue: initialSession.testStripPaperSize.heightCentimeters)
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
        _washTemperature = State(initialValue: initialSession.washTemperatureCelsius)
        _isToningEnabled = State(initialValue: initialSession.isToningEnabled)
        let toner = initialSession.toner ?? DarkroomCatalog.toners.first ?? initialSession.fixer
        _selectedToner = State(initialValue: toner)
        _selectedTonerDilution = State(initialValue: initialSession.tonerDilution ?? toner.dilutions[0])
        _selectedTonerTemperature = State(initialValue: initialSession.toningTemperatureCelsius)
        _tonerVolumeMilliliters = State(initialValue: initialSession.toningVolumeMilliliters)
        _toningSeconds = State(initialValue: Int(initialSession.toningDuration.rounded()))
        _phaseDurationOverrides = State(
            initialValue: initialSession.phaseDurationOverrides.mapValues { Int($0.rounded()) }
        )
        _sessionID = State(initialValue: initialSession.id)
    }

    var body: some View {
        screen
            .background(setupChangeTrackers)
    }

    private var screen: some View {
        ZStack {
            DarkroomPalette.black
                .ignoresSafeArea()

            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 28) {
                    topBar
                        .padding(.top, 8)

                    if isEditingFinishedRun {
                        finishedRunNotice
                    }

                    projectResetButton

                    presetsSection
                    paperSection
                    testStripSection
                    developerSection
                    stopBathSection
                    fixerSection
                    washSection
                    toningSection
                    processSection

                    documentationLegend
                }
                .padding(20)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)

            if let pendingReset {
                resetConfirmationOverlay(for: pendingReset)
            }
        }
        .preferredColorScheme(.dark)
        .statusBar(hidden: true)
        .onAppear {
            isNavigatingToSettings = false
            registerCurrentVolumes()
        }
        // Every change lands in the running project immediately – no need to leave setup.
        .onChange(of: computedSession) { _, session in
            guard !isResettingProject else { return }
            onApply(session)
        }
        .sheet(item: $activePicker) { picker in
            AnyView(pickerSheet(for: picker))
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
                .presentationBackground(DarkroomPalette.black)
                .safeAreaInset(edge: .top, spacing: 0) {
                    Capsule()
                        .fill(DarkroomPalette.red)
                        .frame(width: 40, height: 5)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)
                        .padding(.bottom, 6)
                        .background(DarkroomPalette.black)
                }
        }
    }

    /// Keep volume / override observers off the main screen type. Wrapping the whole
    /// form in generic `onChange` helpers made Swift metadata recurse until the stack died.
    private var setupChangeTrackers: some View {
        Color.clear
            .accessibilityHidden(true)
            .onChange(of: volumeSnapshot) { _, snapshot in
                registerVolume(snapshot.developer, chemical: selectedDeveloper, dilution: selectedDeveloperDilution)
                registerVolume(snapshot.stopBath, chemical: selectedStopBath, dilution: selectedStopBathDilution)
                registerVolume(snapshot.fixer, chemical: selectedFixer, dilution: selectedFixerDilution)
                registerVolume(snapshot.toner, chemical: selectedToner, dilution: selectedTonerDilution)
            }
            .onChange(of: overrideIdentity) { old, new in
                applyStaleOverrideCleanup(from: old, to: new)
            }
    }

    private var volumeSnapshot: SetupVolumeSnapshot {
        SetupVolumeSnapshot(
            developer: developerVolumeMilliliters,
            stopBath: stopBathVolumeMilliliters,
            fixer: fixerVolumeMilliliters,
            toner: tonerVolumeMilliliters
        )
    }

    private var overrideIdentity: SetupOverrideIdentity {
        SetupOverrideIdentity(
            paperID: selectedPaper.id,
            developerID: selectedDeveloper.id,
            developerDilutionID: selectedDeveloperDilution.id,
            developerTemperature: selectedDeveloperTemperature,
            stopBathID: selectedStopBath.id,
            stopBathDilutionID: selectedStopBathDilution.id,
            stopBathTemperature: selectedStopBathTemperature,
            fixerID: selectedFixer.id,
            fixerDilutionID: selectedFixerDilution.id,
            fixerTemperature: selectedFixerTemperature,
            washTemperature: washTemperature,
            tonerID: selectedToner.id,
            tonerDilutionID: selectedTonerDilution.id
        )
    }

    /// A manual time belongs to one combination of paper + chemistry + temperature.
    /// Once any of those changes the override is stale, so it is dropped.
    private func applyStaleOverrideCleanup(from old: SetupOverrideIdentity, to new: SetupOverrideIdentity) {
        if old.paperID != new.paperID {
            phaseDurationOverrides.removeAll()
            return
        }
        if old.developerID != new.developerID
            || old.developerDilutionID != new.developerDilutionID
            || old.developerTemperature != new.developerTemperature {
            phaseDurationOverrides[.developer] = nil
        }
        if old.stopBathID != new.stopBathID
            || old.stopBathDilutionID != new.stopBathDilutionID
            || old.stopBathTemperature != new.stopBathTemperature {
            phaseDurationOverrides[.stopBath] = nil
        }
        if old.fixerID != new.fixerID
            || old.fixerDilutionID != new.fixerDilutionID
            || old.fixerTemperature != new.fixerTemperature {
            phaseDurationOverrides[.fixer] = nil
        }
        if old.washTemperature != new.washTemperature {
            phaseDurationOverrides[.wash] = nil
        }
        if old.tonerID != new.tonerID || old.tonerDilutionID != new.tonerDilutionID {
            phaseDurationOverrides[.toning] = nil
        }
    }

    private func resetConfirmationOverlay(for kind: ResetKind) -> some View {
        ZStack {
            DarkroomPalette.black.opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.15)) { pendingReset = nil }
                }

            VStack(spacing: 20) {
                Text(copy.confirmTitle)
                    .darkroomFont(28, weight: .bold)

                Text(kind == .project ? copy.confirmProjectMessage : copy.confirmSetupMessage)
                    .darkroomFont(15, weight: .semibold)
                    .multilineTextAlignment(.center)
                    .opacity(0.8)

                VStack(spacing: 12) {
                    confirmationChoiceButton(title: copy.confirmYes, filled: false) {
                        performReset(kind)
                    }

                    confirmationChoiceButton(title: copy.confirmNo, filled: true) {
                        withAnimation(.easeInOut(duration: 0.15)) { pendingReset = nil }
                    }
                }
            }
            .foregroundStyle(DarkroomPalette.red)
            .padding(26)
            .frame(maxWidth: 360)
            .background(RoundedRectangle(cornerRadius: 24).fill(DarkroomPalette.black))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(DarkroomPalette.red, lineWidth: 2)
            )
            .padding(32)
        }
    }

    private func confirmationChoiceButton(
        title: String,
        filled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .darkroomFont(17, weight: .bold)
                .foregroundStyle(filled ? DarkroomPalette.black : DarkroomPalette.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(filled ? DarkroomPalette.red : DarkroomPalette.black)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(DarkroomPalette.red, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }

    private func performReset(_ kind: ResetKind) {
        switch kind {
        case .setup:
            withAnimation(.easeInOut(duration: 0.15)) { pendingReset = nil }
            resetToDefaults()
        case .project:
            isResettingProject = true
            pendingReset = nil
            onResetProject()
            goBack()
        }
    }

    private func goBack() {
        if let onBack {
            onBack()
        } else {
            dismiss()
        }
    }

    private var topBar: some View {
        HStack {
            circularIconButton(systemName: "chevron.left") {
                goBack()
            }

            Spacer()

            Text(copy.setupTitle)
                .darkroomFont(24, weight: .bold)
                .foregroundStyle(DarkroomPalette.red)

            Spacer()

            circularIconButton(systemName: "gearshape") {
                isNavigatingToSettings = true
                onOpenSettings()
            }
        }
    }

    private var finishedRunNotice: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle")
                .darkroomFont(16, weight: .bold)

            Text(copy.finishedRunNotice)
                .darkroomFont(14, weight: .semibold)
                .multilineTextAlignment(.leading)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(DarkroomPalette.red)
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(DarkroomPalette.red, lineWidth: 2)
        )
        .accessibilityElement(children: .combine)
    }

    private var projectResetButton: some View {
        HStack(spacing: 12) {
            resetActionButton(title: copy.resetProject) {
                withAnimation(.easeInOut(duration: 0.15)) { pendingReset = .project }
            }

            resetActionButton(title: copy.resetSetup) {
                withAnimation(.easeInOut(duration: 0.15)) { pendingReset = .setup }
            }
        }
    }

    private func resetActionButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .darkroomFont(16, weight: .bold)
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
            id: sessionID,
            paper: selectedPaper,
            paperSize: selectedPaperSize,
            testStripPaper: selectedTestStripPaper,
            testStripPaperSize: selectedTestStripPaperSize,
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
            washTemperatureCelsius: washTemperature,
            isToningEnabled: isToningEnabled,
            toner: isToningEnabled ? selectedToner : nil,
            tonerDilution: isToningEnabled ? selectedTonerDilution : nil,
            toningTemperatureCelsius: selectedTonerTemperature,
            toningVolumeMilliliters: tonerVolumeMilliliters,
            toningDuration: TimeInterval(toningSeconds),
            phaseDurationOverrides: phaseDurationOverrides.mapValues(TimeInterval.init)
        )
    }

    /// Tells the usage ledger how much solution is in the tray. Adding fresh chemistry
    /// revives the bath proportionally, pouring some out leaves the percentage as it was.
    private func registerVolume(_ milliliters: Int, chemical: Chemical, dilution: ChemicalDilution) {
        usageStore.registerVolume(
            Double(milliliters) / 1_000,
            chemical: chemical,
            dilution: dilution
        )
    }

    private func registerCurrentVolumes() {
        registerVolume(developerVolumeMilliliters, chemical: selectedDeveloper, dilution: selectedDeveloperDilution)
        registerVolume(stopBathVolumeMilliliters, chemical: selectedStopBath, dilution: selectedStopBathDilution)
        registerVolume(fixerVolumeMilliliters, chemical: selectedFixer, dilution: selectedFixerDilution)

        if isToningEnabled {
            registerVolume(tonerVolumeMilliliters, chemical: selectedToner, dilution: selectedTonerDilution)
        }
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
            selectionSheet(title: copy.pickPaper) {
                brandFilterBar(brands: DarkroomCatalog.paperManufacturers)
                ForEach(filteredPapers) { paper in
                    selectionButton(
                        title: paper.displayName,
                        subtitle: copy.paperTypeName(paper.type),
                        isSelected: paper.id == selectedPaper.id
                    ) {
                        applyPaperSelection(paper)
                        activePicker = nil
                    }
                }
            }
        case .paperSize:
            sizeSelectionSheet(
                title: copy.pickSize,
                paper: selectedPaper,
                selectedSize: selectedPaperSize
            ) { size in
                selectedPaperSize = size
            } onCustom: {
                customWidthCentimeters = snappedCustomSize(selectedPaperSize.widthCentimeters)
                customHeightCentimeters = snappedCustomSize(selectedPaperSize.heightCentimeters)
                activePicker = .customPaperSize
            }
        case .customPaperSize:
            customSizePickerSheet { size in
                selectedPaperSize = size
            }
        case .testStripPaper:
            selectionSheet(title: copy.pickPaper) {
                brandFilterBar(brands: DarkroomCatalog.paperManufacturers)
                ForEach(filteredPapers) { paper in
                    selectionButton(
                        title: paper.displayName,
                        subtitle: copy.paperTypeName(paper.type),
                        isSelected: paper.id == selectedTestStripPaper.id
                    ) {
                        applyTestStripPaperSelection(paper)
                        activePicker = nil
                    }
                }
            }
        case .testStripPaperSize:
            sizeSelectionSheet(
                title: copy.pickSize,
                paper: selectedTestStripPaper,
                selectedSize: selectedTestStripPaperSize
            ) { size in
                selectedTestStripPaperSize = size
            } onCustom: {
                customWidthCentimeters = snappedCustomSize(selectedTestStripPaperSize.widthCentimeters)
                customHeightCentimeters = snappedCustomSize(selectedTestStripPaperSize.heightCentimeters)
                activePicker = .customTestStripPaperSize
            }
        case .customTestStripPaperSize:
            customSizePickerSheet { size in
                selectedTestStripPaperSize = size
            }
        case .developer:
            selectionSheet(title: copy.pickDeveloper) {
                brandFilterBar(brands: documentedChemicalBrands(in: DarkroomCatalog.developers))
                ForEach(filteredDocumentedChemicals(DarkroomCatalog.developers)) { developer in
                    selectionButton(
                        title: developer.displayName,
                        subtitle: developer.dilutions.map(\.ratio).joined(separator: ", "),
                        isSelected: developer.id == selectedDeveloper.id
                    ) {
                        selectedDeveloper = developer
                        selectedDeveloperDilution = developer.preferredDilution(for: selectedPaper)
                        selectedDeveloperTemperature = firstTemperature(
                            for: selectedDeveloperDilution,
                            chemicalManufacturer: developer.manufacturer
                        )
                        activePicker = nil
                    }
                }
            }
        case .developerDilution:
            dilutionSheet(
                title: copy.pickDeveloperDilution,
                dilutions: documentedDilutions(for: selectedDeveloper),
                selectedDilution: selectedDeveloperDilution,
                chemicalManufacturer: selectedDeveloper.manufacturer
            ) { dilution in
                selectedDeveloperDilution = dilution
                selectedDeveloperTemperature = firstTemperature(
                    for: dilution,
                    chemicalManufacturer: selectedDeveloper.manufacturer
                )
            }
        case .developerVolume:
            volumePickerSheet(title: copy.pickDeveloperVolume, milliliters: $developerVolumeMilliliters)
        case .developerTemperature:
            temperatureSheet(
                title: copy.pickDeveloperTemperature,
                temperatures: availableTemperatures(
                    for: selectedDeveloperDilution,
                    chemicalManufacturer: selectedDeveloper.manufacturer
                ),
                selectedTemperature: selectedDeveloperTemperature
            ) { temperature in
                selectedDeveloperTemperature = temperature
            }
        case .stopBath:
            selectionSheet(title: copy.pickStopBath) {
                brandFilterBar(brands: documentedChemicalBrands(in: DarkroomCatalog.stopBaths))
                ForEach(filteredDocumentedChemicals(DarkroomCatalog.stopBaths)) { stopBath in
                    selectionButton(
                        title: stopBath.displayName,
                        subtitle: stopBath.dilutions.map(\.ratio).joined(separator: ", "),
                        isSelected: stopBath.id == selectedStopBath.id
                    ) {
                        selectedStopBath = stopBath
                        selectedStopBathDilution = stopBath.preferredDilution(for: selectedPaper)
                        selectedStopBathTemperature = firstTemperature(
                            for: selectedStopBathDilution,
                            chemicalManufacturer: stopBath.manufacturer
                        )
                        activePicker = nil
                    }
                }
            }
        case .stopBathDilution:
            dilutionSheet(
                title: copy.pickStopBathDilution,
                dilutions: documentedDilutions(for: selectedStopBath),
                selectedDilution: selectedStopBathDilution,
                chemicalManufacturer: selectedStopBath.manufacturer
            ) { dilution in
                selectedStopBathDilution = dilution
                selectedStopBathTemperature = firstTemperature(
                    for: dilution,
                    chemicalManufacturer: selectedStopBath.manufacturer
                )
            }
        case .stopBathVolume:
            volumePickerSheet(title: copy.pickStopBathVolume, milliliters: $stopBathVolumeMilliliters)
        case .stopBathTemperature:
            temperatureSheet(
                title: copy.pickStopBathTemperature,
                temperatures: availableTemperatures(
                    for: selectedStopBathDilution,
                    chemicalManufacturer: selectedStopBath.manufacturer
                ),
                selectedTemperature: selectedStopBathTemperature
            ) { temperature in
                selectedStopBathTemperature = temperature
            }
        case .fixer:
            selectionSheet(title: copy.pickFixer) {
                brandFilterBar(brands: documentedChemicalBrands(in: DarkroomCatalog.fixers))
                ForEach(filteredDocumentedChemicals(DarkroomCatalog.fixers)) { fixer in
                    selectionButton(
                        title: fixer.displayName,
                        subtitle: fixer.dilutions.map(\.ratio).joined(separator: ", "),
                        isSelected: fixer.id == selectedFixer.id
                    ) {
                        selectedFixer = fixer
                        selectedFixerDilution = fixer.preferredDilution(for: selectedPaper)
                        selectedFixerTemperature = firstTemperature(
                            for: selectedFixerDilution,
                            chemicalManufacturer: fixer.manufacturer
                        )
                        activePicker = nil
                    }
                }
            }
        case .fixerDilution:
            dilutionSheet(
                title: copy.pickFixerDilution,
                dilutions: documentedDilutions(for: selectedFixer),
                selectedDilution: selectedFixerDilution,
                chemicalManufacturer: selectedFixer.manufacturer
            ) { dilution in
                selectedFixerDilution = dilution
                selectedFixerTemperature = firstTemperature(
                    for: dilution,
                    chemicalManufacturer: selectedFixer.manufacturer
                )
            }
        case .fixerVolume:
            volumePickerSheet(title: copy.pickFixerVolume, milliliters: $fixerVolumeMilliliters)
        case .fixerTemperature:
            temperatureSheet(
                title: copy.pickFixerTemperature,
                temperatures: availableTemperatures(
                    for: selectedFixerDilution,
                    chemicalManufacturer: selectedFixer.manufacturer
                ),
                selectedTemperature: selectedFixerTemperature
            ) { temperature in
                selectedFixerTemperature = temperature
            }
        case .transferAfterDeveloper:
            durationPickerSheet(
                title: copy.pickTransferToStopBath,
                totalSeconds: transferSecondsBinding(for: .afterDeveloper)
            )
        case .transferAfterStopBath:
            durationPickerSheet(
                title: copy.pickTransferToFixer,
                totalSeconds: transferSecondsBinding(for: .afterStopBath)
            )
        case .transferAfterFixer:
            durationPickerSheet(
                title: copy.pickTransferToWash,
                totalSeconds: transferSecondsBinding(for: .afterFixer)
            )
        case .washTemperature:
            temperatureSheet(
                title: copy.pickWaterTemperature,
                temperatures: settingsStore.temperaturePickerValues(
                    celsius: Array(stride(from: 5.0, through: 30.0, by: 1.0))
                ),
                selectedTemperature: washTemperature
            ) { temperature in
                washTemperature = temperature
            }
        case .toner:
            selectionSheet(title: copy.pickToner) {
                brandFilterBar(brands: documentedChemicalBrands(in: DarkroomCatalog.toners))
                ForEach(filteredDocumentedChemicals(DarkroomCatalog.toners)) { toner in
                    selectionButton(
                        title: toner.displayName,
                        subtitle: toner.dilutions.map(\.ratio).joined(separator: ", "),
                        isSelected: toner.id == selectedToner.id
                    ) {
                        selectedToner = toner
                        selectedTonerDilution = toner.preferredDilution(for: selectedPaper)
                        activePicker = nil
                    }
                }
            }
        case .tonerDilution:
            dilutionSheet(
                title: copy.pickTonerDilution,
                dilutions: documentedDilutions(for: selectedToner),
                selectedDilution: selectedTonerDilution,
                chemicalManufacturer: selectedToner.manufacturer
            ) { dilution in
                selectedTonerDilution = dilution
            }
        case .tonerVolume:
            volumePickerSheet(title: copy.pickTonerVolume, milliliters: $tonerVolumeMilliliters)
        case .tonerTemperature:
            temperatureSheet(
                title: copy.pickToningBathTemperature,
                temperatures: settingsStore.temperaturePickerValues(
                    celsius: Array(stride(from: 15.0, through: 35.0, by: 1.0))
                ),
                selectedTemperature: selectedTonerTemperature
            ) { temperature in
                selectedTonerTemperature = temperature
            }
        case .toningDuration:
            durationPickerSheet(
                title: copy.pickToningTime,
                totalSeconds: $toningSeconds
            )
        case .processDeveloperDuration:
            processDurationPickerSheet(title: copy.pickProcessDeveloperTime, phase: .developer)
        case .processTransferToStopBathDuration:
            processDurationPickerSheet(title: copy.pickProcessTransferToStopBathTime, phase: .transferToStopBath)
        case .processStopBathDuration:
            processDurationPickerSheet(title: copy.pickProcessStopBathTime, phase: .stopBath)
        case .processTransferToFixerDuration:
            processDurationPickerSheet(title: copy.pickProcessTransferToFixerTime, phase: .transferToFixer)
        case .processFixerDuration:
            processDurationPickerSheet(title: copy.pickProcessFixerTime, phase: .fixer)
        case .processTransferToWashDuration:
            processDurationPickerSheet(title: copy.pickProcessTransferToWashTime, phase: .transferToWash)
        case .processWashDuration:
            processDurationPickerSheet(title: copy.pickProcessWashTime, phase: .wash)
        case .processToningDuration:
            processDurationPickerSheet(title: copy.pickToningTime, phase: .toning)
        }
    }

    private func dilutionSheet(
        title: String,
        dilutions: [ChemicalDilution],
        selectedDilution: ChemicalDilution,
        chemicalManufacturer: String,
        onSelect: @escaping (ChemicalDilution) -> Void
    ) -> some View {
        selectionSheet(title: title) {
            ForEach(dilutions) { dilution in
                let temperature = firstTemperature(for: dilution, chemicalManufacturer: chemicalManufacturer)
                selectionButton(
                    title: dilution.ratio,
                    subtitle: dilution.timeRange(
                        for: selectedPaper,
                        temperatureCelsius: temperature,
                        chemicalManufacturer: chemicalManufacturer
                    ).displayText,
                    isSelected: dilution.id == selectedDilution.id
                ) {
                    onSelect(dilution)
                    activePicker = nil
                }
            }
        }
    }

    private func sizeSelectionSheet(
        title: String,
        paper: Paper,
        selectedSize: PaperSize,
        onSelect: @escaping (PaperSize) -> Void,
        onCustom: @escaping () -> Void
    ) -> some View {
        selectionSheet(title: title) {
            ForEach(paper.availableSizes) { size in
                selectionButton(
                    title: sizeText(size),
                    subtitle: nil,
                    isSelected: size.id == selectedSize.id
                ) {
                    onSelect(size)
                    activePicker = nil
                }
            }

            selectionButton(
                title: copy.customSize,
                subtitle: isCustomPaperSize(selectedSize, relativeTo: paper)
                    ? sizeText(selectedSize)
                    : nil,
                isSelected: isCustomPaperSize(selectedSize, relativeTo: paper)
            ) {
                onCustom()
            }
        }
    }

    private func customSizePickerSheet(onConfirm: @escaping (PaperSize) -> Void) -> some View {
        let widthBinding = Binding<Double>(
            get: { customWidthCentimeters },
            set: { customWidthCentimeters = $0 }
        )
        let heightBinding = Binding<Double>(
            get: { customHeightCentimeters },
            set: { customHeightCentimeters = $0 }
        )

        return ZStack {
            DarkroomPalette.black
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Text(copy.customSizeTitle)
                    .darkroomFont(28, weight: .bold)
                    .foregroundStyle(DarkroomPalette.red)

                HStack(spacing: 18) {
                    Picker(copy.widthLabel, selection: widthBinding) {
                        ForEach(customSizeOptions, id: \.self) { value in
                            Text(centimetersText(value))
                                .foregroundStyle(DarkroomPalette.red)
                                .tag(value)
                        }
                    }
                    .pickerStyle(.wheel)

                    Picker(copy.heightLabel, selection: heightBinding) {
                        ForEach(customSizeOptions, id: \.self) { value in
                            Text(centimetersText(value))
                                .foregroundStyle(DarkroomPalette.red)
                                .tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                .foregroundStyle(DarkroomPalette.red)
                .frame(height: 190)

                Button {
                    onConfirm(
                        PaperSize(
                            widthCentimeters: customWidthCentimeters,
                            heightCentimeters: customHeightCentimeters,
                            nativeUnit: settingsStore.preferredLengthUnit
                        )
                    )
                    activePicker = nil
                } label: {
                    Text(copy.confirmYes)
                        .darkroomFont(22, weight: .bold)
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
            .padding(22)
        }
        .preferredColorScheme(.dark)
    }

    /// Whole units only – centimetres in metric, inches in imperial.
    private var customSizeOptions: [Double] {
        switch settingsStore.unitSystem {
        case .metric:
            return Array(stride(from: 1.0, through: 100.0, by: 1.0))
        case .imperial:
            return Array(stride(from: 1.0, through: 40.0, by: 1.0)).map { $0 * 2.54 }
        }
    }

    private func snappedCustomSize(_ value: Double) -> Double {
        let clamped = min(max(customSizeOptions.first ?? 1, value), customSizeOptions.last ?? 100)

        return customSizeOptions.min { lhs, rhs in
            abs(lhs - clamped) < abs(rhs - clamped)
        } ?? clamped
    }

    private func isCustomPaperSize(_ size: PaperSize, relativeTo paper: Paper) -> Bool {
        !paper.availableSizes.contains(where: { $0.id == size.id })
    }

    private func centimetersText(_ value: Double) -> String {
        settingsStore.formatLength(centimeters: value)
    }

    private func sizeText(_ size: PaperSize) -> String {
        settingsStore.formatSize(size)
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
                    .darkroomFont(28, weight: .bold)
                    .foregroundStyle(DarkroomPalette.red)

                Picker(copy.temperatureLabel, selection: selectedTemperatureBinding) {
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
                    .darkroomFont(28, weight: .bold)
                    .foregroundStyle(DarkroomPalette.red)

                HStack(spacing: 18) {
                    Picker(copy.minutesLabel, selection: minutes) {
                        ForEach(0...999, id: \.self) { minute in
                            Text("\(minute) \(copy.minutesUnit)")
                                .foregroundStyle(DarkroomPalette.red)
                        }
                    }
                    .pickerStyle(.wheel)

                    Picker(copy.secondsLabel, selection: seconds) {
                        ForEach(0...59, id: \.self) { second in
                            Text("\(second) \(copy.secondsSuffix)")
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
        let liters = Binding<Int>(
            get: { milliliters.wrappedValue / 1_000 },
            set: { newLiters in
                let mlPart = (milliliters.wrappedValue % 1_000 / 10) * 10
                milliliters.wrappedValue = max(10, newLiters * 1_000 + mlPart)
            }
        )
        let milliliterPart = Binding<Int>(
            get: { (milliliters.wrappedValue % 1_000 / 10) * 10 },
            set: { newMilliliters in
                let literPart = milliliters.wrappedValue / 1_000
                milliliters.wrappedValue = max(10, literPart * 1_000 + newMilliliters)
            }
        )

        return ZStack {
            DarkroomPalette.black
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Text(title)
                    .darkroomFont(28, weight: .bold)
                    .foregroundStyle(DarkroomPalette.red)

                HStack(spacing: 18) {
                    Picker(copy.litersLabel, selection: liters) {
                        ForEach(0...20, id: \.self) { value in
                            Text("\(value) \(copy.litersUnit)")
                                .foregroundStyle(DarkroomPalette.red)
                                .tag(value)
                        }
                    }
                    .pickerStyle(.wheel)

                    Picker(copy.millilitersLabel, selection: milliliterPart) {
                        ForEach(Array(stride(from: 0, through: 990, by: 10)), id: \.self) { value in
                            Text("\(value) \(copy.millilitersUnit)")
                                .foregroundStyle(DarkroomPalette.red)
                                .tag(value)
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
            Text(copy.confirmYes)
                .darkroomFont(22, weight: .bold)
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
                        .darkroomFont(28, weight: .bold)
                        .foregroundStyle(DarkroomPalette.red)
                        .padding(.bottom, 6)

                    content()
                }
                .padding(22)
            }
            .scrollIndicators(.hidden)
        }
        .preferredColorScheme(.dark)
    }

    private func brandFilterBar(brands: [String]) -> some View {
        let resolvedBrands = brands.isEmpty ? DarkroomCatalog.manufacturers : brands

        return VStack(alignment: .leading, spacing: 10) {
            Text(copy.pickBrand)
                .darkroomFont(14, weight: .semibold)
                .foregroundStyle(DarkroomPalette.red.opacity(0.75))

            // Scrolls instead of squeezing every brand into one row – the catalog grows.
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(resolvedBrands, id: \.self) { brand in
                        let isSelected = brand.caseInsensitiveCompare(pickerBrandFilter) == .orderedSame
                        Button {
                            pickerBrandFilter = brand
                        } label: {
                            Text(brand)
                                .darkroomFont(16, weight: .bold)
                                .foregroundStyle(DarkroomPalette.red)
                                .lineLimit(1)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 12)
                                .background(RoundedRectangle(cornerRadius: 14).fill(cardColor))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            DarkroomPalette.red.opacity(isSelected ? 1 : 0.25),
                                            lineWidth: isSelected ? 2 : 1
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        }
        .padding(.bottom, 4)
        .onAppear {
            if !resolvedBrands.contains(where: {
                $0.caseInsensitiveCompare(pickerBrandFilter) == .orderedSame
            }), let first = resolvedBrands.first {
                pickerBrandFilter = first
            }
        }
    }

    private var documentationLegend: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .darkroomFont(14, weight: .bold)
                Text(copy.legendDocumented)
                    .darkroomFont(13, weight: .semibold)
            }
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .darkroomFont(14, weight: .bold)
                Text(copy.legendInterpolated)
                    .darkroomFont(13, weight: .semibold)
            }
        }
        .foregroundStyle(DarkroomPalette.red.opacity(0.75))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 4)
    }

    private func selectionButton(
        title: String,
        subtitle: String?,
        isSelected: Bool,
        isDocumented: Bool? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .darkroomFont(20, weight: .bold)

                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .darkroomFont(18, weight: .bold)

                    if let subtitle {
                        Text(subtitle)
                            .darkroomFont(14, weight: .semibold)
                    }
                }

                Spacer()

                if let isDocumented {
                    Image(systemName: isDocumented ? "checkmark.seal.fill" : "exclamationmark.triangle")
                        .darkroomFont(16, weight: .bold)
                        .opacity(isDocumented ? 1 : 0.8)
                        .accessibilityLabel(isDocumented ? copy.a11yDocumented : copy.a11yInterpolated)
                }
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

    private var presetsSection: SetupCardSection {
        settingsSection(title: copy.sectionPresets) {
            pickerRow(
                title: copy.rowPreset,
                value: presetStore.presets.isEmpty ? copy.noPresetSaved : copy.presetsSavedCount(presetStore.presets.count),
                picker: .presets
            )
        }
    }

    private var paperSection: SetupCardSection {
        settingsSection(title: copy.sectionPaper) {
            pickerRow(title: copy.rowPaperType, value: selectedPaper.displayName, picker: .paper)
            divider
            pickerRow(title: copy.rowSize, value: sizeText(selectedPaperSize), picker: .paperSize)
        }
    }

    private var testStripSection: SetupCardSection {
        settingsSection(title: copy.sectionTestStripPaper) {
            pickerRow(title: copy.rowPaperType, value: selectedTestStripPaper.displayName, picker: .testStripPaper)
            divider
            pickerRow(title: copy.rowSize, value: sizeText(selectedTestStripPaperSize), picker: .testStripPaperSize)
        }
    }

    private var developerSection: SetupCardSection {
        settingsSection(title: copy.sectionDeveloper) {
            pickerRow(title: copy.rowChemistry, value: selectedDeveloper.displayName, picker: .developer)
            divider
            pickerRow(title: copy.rowDilution, value: selectedDeveloperDilution.ratio, picker: .developerDilution)
            divider
            pickerRow(title: copy.rowVolume, value: millilitersText(developerVolumeMilliliters), picker: .developerVolume)
            divider
            mixRows(dilution: selectedDeveloperDilution, totalMilliliters: developerVolumeMilliliters)
            divider
            temperatureRow(
                dilution: selectedDeveloperDilution,
                chemicalManufacturer: selectedDeveloper.manufacturer,
                temperature: selectedDeveloperTemperature,
                picker: .developerTemperature
            )
            divider
            timeRow(
                dilution: selectedDeveloperDilution,
                chemicalManufacturer: selectedDeveloper.manufacturer,
                temperatureCelsius: selectedDeveloperTemperature
            )
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
    }

    private var stopBathSection: SetupCardSection {
        settingsSection(title: copy.sectionStopBath) {
            pickerRow(title: copy.rowChemistry, value: selectedStopBath.displayName, picker: .stopBath)
            divider
            pickerRow(title: copy.rowDilution, value: selectedStopBathDilution.ratio, picker: .stopBathDilution)
            divider
            pickerRow(title: copy.rowVolume, value: millilitersText(stopBathVolumeMilliliters), picker: .stopBathVolume)
            divider
            mixRows(dilution: selectedStopBathDilution, totalMilliliters: stopBathVolumeMilliliters)
            divider
            temperatureRow(
                dilution: selectedStopBathDilution,
                chemicalManufacturer: selectedStopBath.manufacturer,
                temperature: selectedStopBathTemperature,
                picker: .stopBathTemperature
            )
            divider
            timeRow(
                dilution: selectedStopBathDilution,
                chemicalManufacturer: selectedStopBath.manufacturer,
                temperatureCelsius: selectedStopBathTemperature
            )
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
    }

    private var fixerSection: SetupCardSection {
        settingsSection(title: copy.sectionFixer) {
            pickerRow(title: copy.rowChemistry, value: selectedFixer.displayName, picker: .fixer)
            divider
            pickerRow(title: copy.rowDilution, value: selectedFixerDilution.ratio, picker: .fixerDilution)
            divider
            pickerRow(title: copy.rowVolume, value: millilitersText(fixerVolumeMilliliters), picker: .fixerVolume)
            divider
            mixRows(dilution: selectedFixerDilution, totalMilliliters: fixerVolumeMilliliters)
            divider
            temperatureRow(
                dilution: selectedFixerDilution,
                chemicalManufacturer: selectedFixer.manufacturer,
                temperature: selectedFixerTemperature,
                picker: .fixerTemperature
            )
            divider
            timeRow(
                dilution: selectedFixerDilution,
                chemicalManufacturer: selectedFixer.manufacturer,
                temperatureCelsius: selectedFixerTemperature
            )
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
    }

    private var washSection: SetupCardSection {
        settingsSection(title: copy.sectionWash) {
            pickerRow(
                title: copy.rowWaterTemperature,
                value: temperatureText(washTemperature),
                picker: .washTemperature
            )
            divider
            readOnlyRow(
                title: copy.rowWashTime,
                value: durationText(for: selectedPaper.washDuration(for: washTemperature))
            )
        }
    }

    private var toningSection: SetupCardSection {
        settingsSection(title: copy.sectionToning) {
            toningToggleRow

            if isToningEnabled {
                divider
                pickerRow(title: copy.rowChemistry, value: selectedToner.displayName, picker: .toner)
                divider
                pickerRow(title: copy.rowDilution, value: selectedTonerDilution.ratio, picker: .tonerDilution)
                divider
                pickerRow(title: copy.rowVolume, value: millilitersText(tonerVolumeMilliliters), picker: .tonerVolume)
                divider
                mixRows(dilution: selectedTonerDilution, totalMilliliters: tonerVolumeMilliliters)
                divider
                pickerRow(title: copy.rowTemperature, value: temperatureText(selectedTonerTemperature), picker: .tonerTemperature)
                divider
                pickerRow(title: copy.rowTime, value: durationText(for: TimeInterval(toningSeconds)), picker: .toningDuration)
                divider
                capacityRow(chemical: selectedToner, dilution: selectedTonerDilution, totalMilliliters: tonerVolumeMilliliters)
                divider
                usageRow(
                    chemical: selectedToner,
                    dilution: selectedTonerDilution,
                    isSynced: isTonerUsageSynced
                ) {
                    isTonerUsageSynced.toggle()
                } onReset: {
                    usageStore.reset(chemical: selectedToner, dilution: selectedTonerDilution)
                }
            }
        }
    }

    private var processSection: SetupCardSection {
        settingsSection(title: copy.sectionProcess) {
            let phases = computedSession.resolvedPhases()
            ForEach(Array(phases.enumerated()), id: \.element.id) { index, phase in
                pickerRow(
                    title: displayTitle(for: phase.phase),
                    value: durationText(for: phase.duration),
                    picker: processPicker(for: phase.phase)
                )

                if index < phases.count - 1 {
                    divider
                }
            }
        }
    }

    private func settingsSection<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> SetupCardSection {
        SetupCardSection(title: title, cardColor: cardColor, content: content)
    }

    private func pickerRow(title: String, value: String, picker: SetupPicker) -> some View {
        Button {
            openPicker(picker)
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
                openPicker(picker)
            } label: {
                HStack(spacing: 12) {
                    Text(copy.rowTransfer)
                        .darkroomFont(18, weight: .semibold)

                    Spacer(minLength: 16)

                    Text(value)
                        .darkroomFont(18, weight: .bold)

                    Image(systemName: "chevron.right")
                        .darkroomFont(14, weight: .bold)
                }
            }
            .buttonStyle(.plain)

            Button(action: toggleSync) {
                HStack(spacing: 5) {
                    Image(systemName: isSynced ? "checkmark.square.fill" : "square")
                        .darkroomFont(14, weight: .bold)

                    Text(copy.sync)
                        .darkroomFont(12, weight: .bold)
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

    private var toningToggleRow: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                isToningEnabled.toggle()
            }
        } label: {
            HStack {
                Text(copy.sectionToning)
                    .darkroomFont(18, weight: isToningEnabled ? .bold : .semibold)
                Spacer()
                darkroomSwitch(isOn: isToningEnabled)
            }
            .foregroundStyle(DarkroomPalette.red)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func temperatureRow(
        dilution: ChemicalDilution,
        chemicalManufacturer: String,
        temperature: Double,
        picker: SetupPicker
    ) -> some View {
        if availableTemperatures(for: dilution, chemicalManufacturer: chemicalManufacturer).count > 1 {
            pickerRow(title: copy.rowTemperature, value: temperatureText(temperature), picker: picker)
        } else {
            readOnlyRow(title: copy.rowTemperature, value: temperatureText(temperature))
        }
    }

    private func timeRow(
        dilution: ChemicalDilution,
        chemicalManufacturer: String,
        temperatureCelsius: Double
    ) -> some View {
        let documented = dilution.isDocumented(
            for: selectedPaper,
            temperatureCelsius: temperatureCelsius,
            chemicalManufacturer: chemicalManufacturer
        )
        let value = dilution
            .timeRange(
                for: selectedPaper,
                temperatureCelsius: temperatureCelsius,
                chemicalManufacturer: chemicalManufacturer
            )
            .displayText

        return HStack(spacing: 12) {
            Text(copy.rowTime)
                .darkroomFont(18, weight: .semibold)

            Spacer(minLength: 16)

            HStack(spacing: 6) {
                Text(value)
                    .darkroomFont(18, weight: .bold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Image(systemName: documented ? "checkmark.seal.fill" : "exclamationmark.triangle")
                    .darkroomFont(14, weight: .bold)
                    .opacity(documented ? 1 : 0.8)
                    .accessibilityLabel(documented ? copy.a11yDocumented : copy.a11yInterpolated)
            }
        }
        .foregroundStyle(DarkroomPalette.red)
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(copy.rowTime) \(value), \(documented ? copy.a11yDocumented : copy.a11yInterpolated)")
    }

    @ViewBuilder
    private func mixRows(dilution: ChemicalDilution, totalMilliliters: Int) -> some View {
        let mix = dilution.mixComponents(totalMilliliters: totalMilliliters)
        readOnlyRow(title: copy.rowChemicalAmount, value: millilitersText(mix.chemicalMilliliters))
        divider
        readOnlyRow(title: copy.rowWater, value: millilitersText(mix.waterMilliliters))
    }

    private func capacityRow(chemical: Chemical, dilution: ChemicalDilution, totalMilliliters: Int) -> some View {
        let percent = dilution.capacityPercent(
            usages: usageStore.entries(for: chemical, dilution: dilution),
            workingSolutionLiters: Double(totalMilliliters) / 1_000
        )

        return readOnlyRow(
            title: copy.rowCapacity,
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
            Text(copy.rowUsed)
                .darkroomFont(18, weight: .semibold)

            Spacer(minLength: 16)

            Text("\(usageStore.count(for: chemical, dilution: dilution))x")
                .darkroomFont(18, weight: .bold)

            Button(action: onReset) {
                Text(copy.reset)
                    .darkroomFont(13, weight: .bold)
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
                        .darkroomFont(14, weight: .bold)

                    Text(copy.sync)
                        .darkroomFont(12, weight: .bold)
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
                .darkroomFont(18, weight: .semibold)

            Spacer(minLength: 16)

            Text(value)
                .darkroomFont(18, weight: .bold)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.trailing)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .darkroomFont(14, weight: .bold)
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
                .darkroomFont(24, weight: .bold)
                .foregroundStyle(DarkroomPalette.red)
                .frame(width: 56, height: 56)
                .background(Circle().fill(cardColor))
                .overlay(Circle().stroke(DarkroomPalette.red.opacity(0.35), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func availableTemperatures(
        for dilution: ChemicalDilution,
        chemicalManufacturer: String
    ) -> [Double] {
        let temperatures = dilution.availableTemperatures(
            for: selectedPaper,
            chemicalManufacturer: chemicalManufacturer
        )

        // In Fahrenheit mode the wheel steps by whole °F instead of showing
        // converted Celsius steps like 68, 70, 71, 73 °F.
        return settingsStore.temperaturePickerValues(
            celsius: temperatures.isEmpty ? [20] : temperatures,
            documented: dilution.documentedTemperatures(
                for: selectedPaper,
                chemicalManufacturer: chemicalManufacturer
            )
        )
    }

    private func firstTemperature(
        for dilution: ChemicalDilution,
        chemicalManufacturer: String
    ) -> Double {
        availableTemperatures(for: dilution, chemicalManufacturer: chemicalManufacturer).first ?? 20
    }

    private func normalizeTemperatures() {
        selectedDeveloperTemperature = firstTemperature(
            for: selectedDeveloperDilution,
            chemicalManufacturer: selectedDeveloper.manufacturer
        )
        selectedStopBathTemperature = firstTemperature(
            for: selectedStopBathDilution,
            chemicalManufacturer: selectedStopBath.manufacturer
        )
        selectedFixerTemperature = firstTemperature(
            for: selectedFixerDilution,
            chemicalManufacturer: selectedFixer.manufacturer
        )
    }

    private var filteredPapers: [Paper] {
        DarkroomCatalog.papers.filter {
            $0.manufacturer.caseInsensitiveCompare(pickerBrandFilter) == .orderedSame
        }
    }

    private func documentedChemicalBrands(in chemicals: [Chemical]) -> [String] {
        Array(
            Set(
                chemicals
                    .filter { $0.isApplicable(for: selectedPaper) }
                    .map(\.manufacturer)
            )
        ).sorted()
    }

    private func filteredDocumentedChemicals(_ chemicals: [Chemical]) -> [Chemical] {
        chemicals.filter {
            $0.isApplicable(for: selectedPaper)
                && $0.manufacturer.caseInsensitiveCompare(pickerBrandFilter) == .orderedSame
        }
    }

    private func documentedDilutions(for chemical: Chemical) -> [ChemicalDilution] {
        let applicable = chemical.dilutions.filter { dilution in
            if dilution.isApplicable(for: selectedPaper, chemicalManufacturer: chemical.manufacturer) {
                return true
            }

            guard chemical.role == .toner else {
                return false
            }

            return dilution.capacityRules.contains {
                $0.paperID == nil && $0.paperType == selectedPaper.type
            }
        }
        return applicable.isEmpty ? chemical.dilutions : applicable
    }

    private func openPicker(_ picker: SetupPicker) {
        pickerBrandFilter = initialBrand(for: picker)
        activePicker = picker
    }

    private func initialBrand(for picker: SetupPicker) -> String {
        switch picker {
        case .paper:
            return selectedPaper.manufacturer
        case .testStripPaper:
            return selectedTestStripPaper.manufacturer
        case .developer:
            return selectedDeveloper.manufacturer
        case .stopBath:
            return selectedStopBath.manufacturer
        case .fixer:
            return selectedFixer.manufacturer
        case .toner:
            return selectedToner.manufacturer
        default:
            return selectedPaper.manufacturer
        }
    }

    private func applyPaperSelection(_ paper: Paper) {
        let previousSize = selectedPaperSize
        selectedPaper = paper
        if paper.availableSizes.contains(where: { $0.id == previousSize.id }) {
            selectedPaperSize = previousSize
        } else if isCustomPaperSize(previousSize, relativeTo: paper) {
            selectedPaperSize = previousSize
        } else {
            selectedPaperSize = paper.availableSizes.first ?? previousSize
        }
        syncChemistry(to: paper)
        normalizeTemperatures()
    }

    private func applyTestStripPaperSelection(_ paper: Paper) {
        let previousSize = selectedTestStripPaperSize
        selectedTestStripPaper = paper
        if paper.availableSizes.contains(where: { $0.id == previousSize.id }) {
            selectedTestStripPaperSize = previousSize
        } else if isCustomPaperSize(previousSize, relativeTo: paper) {
            selectedTestStripPaperSize = previousSize
        } else {
            selectedTestStripPaperSize = paper.availableSizes.first ?? previousSize
        }
    }

    private func syncChemistry(to paper: Paper) {
        if !selectedDeveloper.isApplicable(for: paper),
           let developer = DarkroomCatalog.developers.first(where: { $0.isApplicable(for: paper) }) {
            selectedDeveloper = developer
            selectedDeveloperDilution = developer.preferredDilution(for: paper)
        } else if !selectedDeveloperDilution.isApplicable(
            for: paper,
            chemicalManufacturer: selectedDeveloper.manufacturer
        ) {
            selectedDeveloperDilution = selectedDeveloper.preferredDilution(for: paper)
        }

        if !selectedStopBath.isApplicable(for: paper),
           let stopBath = DarkroomCatalog.stopBaths.first(where: { $0.isApplicable(for: paper) }) {
            selectedStopBath = stopBath
            selectedStopBathDilution = stopBath.preferredDilution(for: paper)
        } else if !selectedStopBathDilution.isApplicable(
            for: paper,
            chemicalManufacturer: selectedStopBath.manufacturer
        ) {
            selectedStopBathDilution = selectedStopBath.preferredDilution(for: paper)
        }

        if !selectedFixer.isApplicable(for: paper),
           let fixer = DarkroomCatalog.fixers.first(where: { $0.isApplicable(for: paper) }) {
            selectedFixer = fixer
            selectedFixerDilution = fixer.preferredDilution(for: paper)
        } else if !selectedFixerDilution.isApplicable(
            for: paper,
            chemicalManufacturer: selectedFixer.manufacturer
        ) {
            selectedFixerDilution = selectedFixer.preferredDilution(for: paper)
        }

        if isToningEnabled {
            if !selectedToner.isApplicable(for: paper),
               let toner = DarkroomCatalog.toners.first(where: { $0.isApplicable(for: paper) }) {
                selectedToner = toner
                selectedTonerDilution = toner.preferredDilution(for: paper)
            } else if DarkroomCatalog.toners.contains(where: { $0.isApplicable(for: paper) }) == false {
                isToningEnabled = false
            }
        }
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
        apply(session: DarkroomCatalog.configuredDefaultSession)
    }

    private func apply(session: DevelopmentSession) {
        selectedPaper = session.paper
        selectedPaperSize = session.paperSize
        selectedTestStripPaper = session.testStripPaper
        selectedTestStripPaperSize = session.testStripPaperSize
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
        washTemperature = session.washTemperatureCelsius
        isToningEnabled = session.isToningEnabled
        if let toner = session.toner {
            selectedToner = toner
            selectedTonerDilution = session.tonerDilution ?? toner.dilutions[0]
        }
        selectedTonerTemperature = session.toningTemperatureCelsius
        tonerVolumeMilliliters = session.toningVolumeMilliliters
        toningSeconds = Int(session.toningDuration.rounded())
        phaseDurationOverrides = session.phaseDurationOverrides.mapValues { Int($0.rounded()) }
    }

    private func baseProcessDurationSeconds(for phase: ProcessPhase) -> Int {
        let baseSession = DevelopmentSession(
            paper: selectedPaper,
            paperSize: selectedPaperSize,
            testStripPaper: selectedTestStripPaper,
            testStripPaperSize: selectedTestStripPaperSize,
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
            washTemperatureCelsius: washTemperature,
            isToningEnabled: isToningEnabled,
            toner: isToningEnabled ? selectedToner : nil,
            tonerDilution: isToningEnabled ? selectedTonerDilution : nil,
            toningTemperatureCelsius: selectedTonerTemperature,
            toningVolumeMilliliters: tonerVolumeMilliliters,
            toningDuration: TimeInterval(toningSeconds)
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
        case .toning:
            return .processToningDuration
        }
    }

    private func temperatureText(_ temperature: Double) -> String {
        settingsStore.formatTemperature(temperature)
    }

    private func millilitersText(_ milliliters: Int) -> String {
        "\(milliliters) \(copy.millilitersUnit)"
    }

    private func displayTitle(for phase: ProcessPhase) -> String {
        switch phase {
        case .developer:
            return copy.sectionDeveloper
        case .stopBath:
            return copy.sectionStopBath
        case .fixer:
            return copy.sectionFixer
        case .transferToStopBath:
            return copy.processTransferToStopBath
        case .transferToFixer:
            return copy.processTransferToFixer
        case .transferToWash:
            return copy.processTransferToWash
        case .wash:
            return copy.sectionWash
        case .toning:
            return copy.sectionToning
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
    case customPaperSize
    case testStripPaper
    case testStripPaperSize
    case customTestStripPaperSize
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
    case washTemperature
    case toner
    case tonerDilution
    case tonerVolume
    case tonerTemperature
    case toningDuration
    case processDeveloperDuration
    case processTransferToStopBathDuration
    case processStopBathDuration
    case processTransferToFixerDuration
    case processFixerDuration
    case processTransferToWashDuration
    case processWashDuration
    case processToningDuration

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

/// OFF: prázdný kruh vlevo (jen červený obrys). ON: plný červený kruh vpravo.
/// Dráha je vždy černá.
private func darkroomSwitch(isOn: Bool) -> some View {
    Capsule()
        .fill(DarkroomPalette.black)
        .overlay(
            Capsule()
                .stroke(DarkroomPalette.red, lineWidth: 2)
        )
        .frame(width: 52, height: 32)
        .overlay(
            Circle()
                .fill(isOn ? DarkroomPalette.red : Color.clear)
                .overlay(
                    Circle()
                        .stroke(DarkroomPalette.red, lineWidth: 2)
                )
                .frame(width: 22, height: 22)
                .padding(.horizontal, 5)
                .frame(maxWidth: .infinity, alignment: isOn ? .trailing : .leading)
        )
        .animation(.easeInOut(duration: 0.15), value: isOn)
}

struct SettingsTextPage: View {
    let title: String
    let subtitle: String?
    let sections: [(title: String, body: String)]
    let onBack: () -> Void

    private let cardColor = DarkroomPalette.black

    var body: some View {
        ZStack {
            DarkroomPalette.black
                .ignoresSafeArea()

            VStack(spacing: 18) {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .darkroomFont(24, weight: .bold)
                            .foregroundStyle(DarkroomPalette.red)
                            .frame(width: 56, height: 56)
                            .background(Circle().fill(cardColor))
                            .overlay(Circle().stroke(DarkroomPalette.red.opacity(0.35), lineWidth: 1))
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text(title)
                        .darkroomFont(24, weight: .bold)
                        .foregroundStyle(DarkroomPalette.red)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Spacer()

                    Color.clear
                        .frame(width: 56, height: 56)
                }

                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 22) {
                        if let subtitle {
                            Text(subtitle)
                                .darkroomFont(15, weight: .semibold)
                        }

                        ForEach(Array(sections.enumerated()), id: \.offset) { _, section in
                            VStack(alignment: .leading, spacing: 8) {
                                if !section.title.isEmpty {
                                    Text(section.title)
                                        .darkroomFont(18, weight: .bold)
                                }

                                Text(section.body)
                                    .darkroomFont(16, weight: .regular)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .foregroundStyle(DarkroomPalette.red)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 24)
                    .textSelection(.enabled)
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .preferredColorScheme(.dark)
        .statusBar(hidden: true)
    }
}

struct SettingsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var settingsStore = DarkroomSettingsStore.shared
    @State private var isLanguagePickerPresented = false
    @State private var isRussianBlockedAlertPresented = false
    var onBack: (() -> Void)? = nil
    var onOpenPrivacy: () -> Void = {}
    var onOpenSupport: () -> Void = {}

    private let cardColor = DarkroomPalette.black
    private var copy: AppCopy { settingsStore.copy }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "2.0"
    }

    var body: some View {
        ZStack {
            DarkroomPalette.black
                .ignoresSafeArea()

            VStack(spacing: 18) {
                settingsTopBar

                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 18) {
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
                                            .darkroomFont(18, weight: .regular)
                                        Spacer()
                                        Text("\(Int((settingsStore.darkroomBrightness * 100).rounded())) %")
                                            .darkroomFont(18, weight: .bold)
                                    }
                                    redSlider(
                                        value: $settingsStore.darkroomBrightness,
                                        in: 0.05...0.6,
                                        step: 0.05
                                    )
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
                                value: settingsStore.temperatureUnit.displayName
                            ) {
                                let units = TemperatureUnit.allCases
                                if let index = units.firstIndex(of: settingsStore.temperatureUnit) {
                                    settingsStore.temperatureUnit = units[(index + 1) % units.count]
                                }
                            }

                            settingsDivider

                            optionRow(
                                title: copy.unitSystem,
                                value: settingsStore.unitSystem.displayName(copy: copy)
                            ) {
                                let systems = UnitSystem.allCases
                                if let index = systems.firstIndex(of: settingsStore.unitSystem) {
                                    settingsStore.unitSystem = systems[(index + 1) % systems.count]
                                }
                            }

                            settingsDivider

                            optionRow(
                                title: copy.languageTitle,
                                value: settingsStore.language.displayName
                            ) {
                                isLanguagePickerPresented = true
                            }
                        }

                        settingsCard {
                            readOnlySettingsRow(title: copy.version, value: appVersion)
                            settingsDivider
                            optionRow(title: copy.privacyPolicy, value: "") {
                                onOpenPrivacy()
                            }
                            settingsDivider
                            optionRow(title: copy.support, value: "") {
                                onOpenSupport()
                            }
                            settingsDivider
                            Text(copy.copyright)
                                .darkroomFont(14, weight: .regular)
                                .foregroundStyle(DarkroomPalette.red.opacity(0.85))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 14)
                        }
                    }
                    .padding(.bottom, 24)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .preferredColorScheme(.dark)
        .statusBar(hidden: true)
        .sheet(isPresented: $isLanguagePickerPresented) {
            languagePickerSheet
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
                .presentationBackground(DarkroomPalette.black)
                .safeAreaInset(edge: .top, spacing: 0) {
                    Capsule()
                        .fill(DarkroomPalette.red)
                        .frame(width: 40, height: 5)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)
                        .padding(.bottom, 6)
                        .background(DarkroomPalette.black)
                }
        }
    }

    private var languagePickerSheet: some View {
        ZStack {
            DarkroomPalette.black
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(copy.languageTitle)
                        .darkroomFont(28, weight: .bold)
                        .foregroundStyle(DarkroomPalette.red)
                        .padding(.bottom, 6)

                    ForEach(AppLanguage.allCases) { language in
                        Button {
                            if language.isTemporarilyBlocked {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    isRussianBlockedAlertPresented = true
                                }
                            } else {
                                settingsStore.language = language
                                isLanguagePickerPresented = false
                            }
                        } label: {
                            HStack {
                                Text(language.displayName)
                                    .darkroomFont(20, weight: language == settingsStore.language ? .bold : .regular)
                                    .opacity(language.isTemporarilyBlocked ? 0.55 : 1)
                                Spacer()
                                if language == settingsStore.language {
                                    Image(systemName: "checkmark")
                                        .darkroomFont(18, weight: .bold)
                                }
                            }
                            .foregroundStyle(DarkroomPalette.red)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(cardColor)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(
                                        DarkroomPalette.red.opacity(language == settingsStore.language ? 1 : 0.35),
                                        lineWidth: language == settingsStore.language ? 2 : 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(22)
            }
            .scrollIndicators(.hidden)

            if isRussianBlockedAlertPresented {
                russianBlockedAlertOverlay
            }
        }
        .preferredColorScheme(.dark)
    }

    private var russianBlockedAlertOverlay: some View {
        ZStack {
            DarkroomPalette.black.opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isRussianBlockedAlertPresented = false
                    }
                }

            VStack(spacing: 20) {
                Text(copy.russianLanguageBlockedMessage)
                    .darkroomFont(18, weight: .semibold)
                    .multilineTextAlignment(.center)
                    .opacity(0.95)

                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        isRussianBlockedAlertPresented = false
                    }
                } label: {
                    Text(copy.confirmYes)
                        .darkroomFont(17, weight: .bold)
                        .foregroundStyle(DarkroomPalette.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 16).fill(DarkroomPalette.red))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(DarkroomPalette.red, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
            }
            .foregroundStyle(DarkroomPalette.red)
            .padding(26)
            .frame(maxWidth: 360)
            .background(RoundedRectangle(cornerRadius: 24).fill(DarkroomPalette.black))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(DarkroomPalette.red, lineWidth: 2)
            )
            .padding(32)
        }
    }

    private var settingsTopBar: some View {
        HStack {
            Button {
                goBack()
            } label: {
                Image(systemName: "chevron.left")
                    .darkroomFont(24, weight: .bold)
                    .foregroundStyle(DarkroomPalette.red)
                    .frame(width: 56, height: 56)
                    .background(Circle().fill(cardColor))
                    .overlay(Circle().stroke(DarkroomPalette.red.opacity(0.35), lineWidth: 1))
            }
            .buttonStyle(.plain)

            Spacer()

            Text(copy.settingsTitle)
                .darkroomFont(24, weight: .bold)
                .foregroundStyle(DarkroomPalette.red)

            Spacer()

            Color.clear
                .frame(width: 56, height: 56)
        }
    }

    private func goBack() {
        if let onBack {
            onBack()
        } else {
            dismiss()
        }
    }

    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(RoundedRectangle(cornerRadius: 24).fill(cardColor))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(DarkroomPalette.red.opacity(0.45), lineWidth: 1)
        )
    }

    private var settingsDivider: some View {
        Rectangle()
            .fill(DarkroomPalette.red.opacity(0.35))
            .frame(height: 1)
            .padding(.leading, 18)
    }

    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                isOn.wrappedValue.toggle()
            }
        } label: {
            HStack {
                Text(title)
                    .darkroomFont(18, weight: isOn.wrappedValue ? .bold : .regular)
                Spacer()
                redSwitch(isOn: isOn.wrappedValue)
            }
            .foregroundStyle(DarkroomPalette.red)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    private func redSwitch(isOn: Bool) -> some View {
        darkroomSwitch(isOn: isOn)
    }

    private func redSlider(value: Binding<Double>, in range: ClosedRange<Double>, step: Double) -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let span = range.upperBound - range.lowerBound
            let fraction = span > 0 ? CGFloat((value.wrappedValue - range.lowerBound) / span) : 0
            let clampedFraction = min(max(0, fraction), 1)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(DarkroomPalette.black)
                    .overlay(Capsule().stroke(DarkroomPalette.red.opacity(0.6), lineWidth: 1))
                    .frame(height: 6)

                Capsule()
                    .fill(DarkroomPalette.red)
                    .frame(width: clampedFraction * width, height: 6)

                Circle()
                    .fill(DarkroomPalette.red)
                    .frame(width: 24, height: 24)
                    .offset(x: min(max(0, clampedFraction * width - 12), width - 24))
            }
            .frame(height: 24)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        guard width > 0 else { return }
                        let newFraction = min(max(0, drag.location.x / width), 1)
                        let raw = range.lowerBound + Double(newFraction) * span
                        let stepped = (raw / step).rounded() * step
                        value.wrappedValue = min(range.upperBound, max(range.lowerBound, stepped))
                    }
            )
        }
        .frame(height: 24)
    }

    private func optionRow(title: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(title)
                    .darkroomFont(18, weight: .regular)

                Spacer(minLength: 16)

                if !value.isEmpty {
                    Text(value)
                        .darkroomFont(18, weight: .bold)
                }

                Image(systemName: "chevron.right")
                    .darkroomFont(14, weight: .bold)
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
                .darkroomFont(18, weight: .regular)

            Spacer(minLength: 12)

            Button(action: onDecrement) {
                Image(systemName: "minus")
                    .darkroomFont(16, weight: .bold)
                    .frame(width: 36, height: 36)
                    .overlay(Circle().stroke(DarkroomPalette.red.opacity(0.45), lineWidth: 1))
            }
            .buttonStyle(.plain)

            Text(valueText)
                .darkroomFont(18, weight: .bold)
                .frame(minWidth: 48)

            Button(action: onIncrement) {
                Image(systemName: "plus")
                    .darkroomFont(16, weight: .bold)
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
                .darkroomFont(18, weight: .regular)

            Spacer(minLength: 16)

            Text(value)
                .darkroomFont(18, weight: .bold)
        }
        .foregroundStyle(DarkroomPalette.red)
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
    }
}

private struct PresetsSheetView: View {
    @ObservedObject private var presetStore = PresetStore.shared
    @ObservedObject private var settingsStore = DarkroomSettingsStore.shared
    @State private var pendingAction: PendingPresetAction?

    let session: DevelopmentSession
    let onLoad: (DevelopmentSession) -> Void

    private let cardColor = DarkroomPalette.black
    private var copy: AppCopy { settingsStore.copy }

    private enum PendingPresetAction {
        case overwrite(DevelopmentPreset)
        case delete(DevelopmentPreset)

        var preset: DevelopmentPreset {
            switch self {
            case .overwrite(let preset), .delete(let preset):
                return preset
            }
        }
    }

    var body: some View {
        ZStack {
            DarkroomPalette.black
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(copy.presetsTitle)
                        .darkroomFont(28, weight: .bold)
                        .foregroundStyle(DarkroomPalette.red)
                        .padding(.bottom, 4)

                    Text(copy.savePresetHeader)
                        .darkroomFont(16, weight: .bold)
                        .foregroundStyle(DarkroomPalette.red)

                    ForEach(DevelopmentPreset.alphabetLetters, id: \.self) { letter in
                        presetSlot(letter: letter)
                    }
                }
                .padding(22)
            }
            .scrollIndicators(.hidden)

            if let pendingAction {
                confirmationOverlay(for: pendingAction)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func presetSlot(letter: String) -> some View {
        // Stored name stays "Preset X" (it is the slot identity); only the label is localized.
        let name = copy.presetSlotName(letter)
        let preset = presetStore.preset(forLetter: letter)

        return HStack(spacing: 10) {
            Button {
                if let preset {
                    onLoad(preset.session)
                } else {
                    presetStore.save(letter: letter, session: session)
                }
            } label: {
                VStack(alignment: .leading, spacing: 5) {
                    Text(name)
                        .darkroomFont(18, weight: .bold)

                    Text(preset?.session.paper.displayName ?? copy.emptyPresetSlot)
                        .darkroomFont(13, weight: .semibold)
                        .lineLimit(1)
                }
                .foregroundStyle(DarkroomPalette.red)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            if let preset {
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        pendingAction = .overwrite(preset)
                    }
                } label: {
                    presetActionLabel(copy.overwritePreset)
                }
                .buttonStyle(.plain)

                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        pendingAction = .delete(preset)
                    }
                } label: {
                    presetActionLabel(copy.deletePreset)
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    presetStore.save(letter: letter, session: session)
                } label: {
                    presetActionLabel(copy.savePresetButton)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 18).fill(cardColor))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(DarkroomPalette.red.opacity(preset == nil ? 0.25 : 0.45), lineWidth: 1)
        )
    }

    private func presetActionLabel(_ title: String) -> some View {
        Text(title)
            .darkroomFont(12, weight: .bold)
            .foregroundStyle(DarkroomPalette.red)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .overlay(
                Capsule()
                    .stroke(DarkroomPalette.red, lineWidth: 1)
            )
    }

    private func presetDisplayName(_ preset: DevelopmentPreset) -> String {
        preset.letter.map { copy.presetSlotName($0) } ?? preset.name
    }

    private func confirmationOverlay(for action: PendingPresetAction) -> some View {
        let message: String = {
            switch action {
            case .overwrite(let preset):
                return copy.confirmOverwritePresetMessage(presetDisplayName(preset))
            case .delete(let preset):
                return copy.confirmDeletePresetMessage(presetDisplayName(preset))
            }
        }()

        return ZStack {
            DarkroomPalette.black.opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.15)) { pendingAction = nil }
                }

            VStack(spacing: 20) {
                Text(copy.confirmTitle)
                    .darkroomFont(28, weight: .bold)

                Text(message)
                    .darkroomFont(15, weight: .semibold)
                    .multilineTextAlignment(.center)
                    .opacity(0.8)

                VStack(spacing: 12) {
                    Button {
                        perform(action)
                        withAnimation(.easeInOut(duration: 0.15)) { pendingAction = nil }
                    } label: {
                        Text(copy.confirmYes)
                            .darkroomFont(17, weight: .bold)
                            .foregroundStyle(DarkroomPalette.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(RoundedRectangle(cornerRadius: 16).fill(DarkroomPalette.black))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(DarkroomPalette.red, lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)

                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { pendingAction = nil }
                    } label: {
                        Text(copy.confirmNo)
                            .darkroomFont(17, weight: .bold)
                            .foregroundStyle(DarkroomPalette.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(RoundedRectangle(cornerRadius: 16).fill(DarkroomPalette.red))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(DarkroomPalette.red, lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .foregroundStyle(DarkroomPalette.red)
            .padding(26)
            .frame(maxWidth: 360)
            .background(RoundedRectangle(cornerRadius: 24).fill(DarkroomPalette.black))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(DarkroomPalette.red, lineWidth: 2)
            )
            .padding(32)
        }
    }

    private func perform(_ action: PendingPresetAction) {
        switch action {
        case .overwrite(let preset):
            presetStore.overwrite(preset, with: session)
        case .delete(let preset):
            presetStore.delete(preset)
        }
    }
}

/// Type-erased card so SetupView's `body` is a handful of named views, not one giant generic.
private struct SetupCardSection: View {
    let title: String
    let cardColor: Color
    let content: AnyView

    init<Content: View>(
        title: String,
        cardColor: Color,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.cardColor = cardColor
        self.content = AnyView(content())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .darkroomFont(16, weight: .semibold)
                .foregroundStyle(DarkroomPalette.red)
                .padding(.leading, 18)

            VStack(spacing: 0) {
                content
            }
            .background(RoundedRectangle(cornerRadius: 24).fill(cardColor))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(DarkroomPalette.red.opacity(0.45), lineWidth: 1)
            )
        }
    }
}

private struct SetupVolumeSnapshot: Equatable {
    var developer: Int
    var stopBath: Int
    var fixer: Int
    var toner: Int
}

private struct SetupOverrideIdentity: Equatable {
    var paperID: String
    var developerID: String
    var developerDilutionID: String
    var developerTemperature: Double
    var stopBathID: String
    var stopBathDilutionID: String
    var stopBathTemperature: Double
    var fixerID: String
    var fixerDilutionID: String
    var fixerTemperature: Double
    var washTemperature: Double
    var tonerID: String
    var tonerDilutionID: String
}

#Preview {
    SetupView(initialSession: DarkroomCatalog.defaultSession) { _ in }
}
