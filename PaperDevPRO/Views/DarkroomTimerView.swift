import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

public enum DarkroomPalette {
    public static let black = Color(red: 0, green: 0, blue: 0)
    public static let red = Color(red: 1, green: 0, blue: 0)
}

public enum SetupRoute: Hashable {
    case setup
    case settings
}

@MainActor
public struct DarkroomTimerView: View {
    @StateObject private var viewModel: TimerViewModel
    @ObservedObject private var settingsStore = DarkroomSettingsStore.shared
    @State private var navigationPath: [SetupRoute] = []
    @State private var pendingDeleteRunID: UUID?

    public init(session: DevelopmentSession? = nil) {
        let resolvedSession = session ?? MockDarkroomDatabase.configuredDefaultSession
        _viewModel = StateObject(wrappedValue: TimerViewModel(session: resolvedSession))
    }

    public init(viewModel: TimerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private var copy: AppCopy { settingsStore.copy }

    public var body: some View {
        NavigationStack(path: $navigationPath) {
            timerContent
                .navigationDestination(for: SetupRoute.self) { route in
                    destinationView(for: route)
                        .navigationBarBackButtonHidden(true)
                        .toolbar(.hidden, for: .navigationBar)
                }
        }
        .tint(DarkroomPalette.red)
    }

    @ViewBuilder
    private func destinationView(for route: SetupRoute) -> some View {
        switch route {
        case .setup:
            SetupView(
                initialSession: viewModel.session,
                onResetProject: {
                    viewModel.resetProject()
                },
                onOpenSettings: {
                    navigationPath.append(.settings)
                }
            ) { session in
                viewModel.configureSelectedRun(session: session)
            }
        case .settings:
            SettingsSheetView()
        }
    }

    private var timerContent: some View {
        GeometryReader { geometry in
            ZStack {
                DarkroomPalette.black
                    .ignoresSafeArea()

                VStack(spacing: 22) {
                    paperRunTimeline

                    if viewModel.hasRuns {
                        phaseTimeline

                        phaseHeader

                        Spacer(minLength: 0)

                        Text(viewModel.formattedRemainingTime)
                            .font(.system(size: timerFontSize(for: geometry.size), weight: .bold, design: .monospaced))
                            .minimumScaleFactor(0.35)
                            .lineLimit(1)
                            .accessibilityLabel(accessibilityTimerLabel)

                        statusText

                        Spacer(minLength: 0)
                    } else {
                        controlsHintView
                            .padding(.top, 28)

                        Spacer(minLength: 0)

                        VStack(spacing: 12) {
                            Text("PaperDeveloper")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(DarkroomPalette.red)

                            Text(copy.safelightWarning)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(DarkroomPalette.red.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 8)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("PaperDeveloper. \(copy.safelightWarning)")

                        Spacer(minLength: 0)
                    }

                    controlButtons
                }
                .foregroundStyle(DarkroomPalette.red)
                .multilineTextAlignment(.center)
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                if pendingDeleteRunID != nil {
                    deleteRunConfirmationOverlay
                }
            }
        }
        .background(DarkroomPalette.black)
        .preferredColorScheme(.dark)
        .statusBar(hidden: true)
        .onAppear {
            settingsStore.applyKeepScreenOn()
        }
        .onChange(of: settingsStore.keepScreenOn) { _, _ in
            settingsStore.applyKeepScreenOn()
        }
    }

    private var paperRunTimeline: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Text("+")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(DarkroomPalette.red)
                    .frame(width: 58, height: 58)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(DarkroomPalette.red, lineWidth: 2)
                    )
                    .contentShape(RoundedRectangle(cornerRadius: 14))
                    .onTapGesture {
                        viewModel.addPaperRun()
                    }
                    .onLongPressGesture(minimumDuration: 0.45) {
                        viewModel.addTestStripRun()
                    }
                    .accessibilityLabel(copy.paper)
                    .accessibilityHint(copy.longPressAddStripHint)

                ForEach(Array(viewModel.runs.reversed())) { run in
                    paperRunCard(for: run)
                        .contentShape(RoundedRectangle(cornerRadius: 14))
                        .onTapGesture {
                            viewModel.selectRun(id: run.id)
                        }
                        .onLongPressGesture(minimumDuration: 0.45) {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                pendingDeleteRunID = run.id
                            }
                        }
                }
            }
            .padding(.horizontal, 2)
        }
        .frame(height: 70)
    }

    private var controlsHintView: some View {
        VStack(alignment: .leading, spacing: 18) {
            hintLine(copy.controlsHintAddPaper)
            hintLine(copy.controlsHintAddStrip)
            hintLine(copy.controlsHintDelete)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(copy.controlsHint)
    }

    private func hintLine(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 22, weight: .semibold))
            .foregroundStyle(DarkroomPalette.red)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func paperRunCard(for run: TimerViewModel.PaperRun) -> some View {
        let isSelected = run.id == viewModel.selectedRunID
        let title = run.isTestStrip
            ? "\(copy.testStrip) \(run.number)"
            : "\(copy.paper) \(run.number)"

        return VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 17, weight: .bold))

            Text(runStatusText(for: run))
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .lineLimit(1)
        }
        .foregroundStyle(DarkroomPalette.red)
        .padding(.horizontal, 12)
        .frame(width: 132, height: 58, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(DarkroomPalette.red, lineWidth: isSelected ? 3 : 1)
        )
    }

    private var deleteRunConfirmationOverlay: some View {
        ZStack {
            DarkroomPalette.black.opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.15)) { pendingDeleteRunID = nil }
                }

            VStack(spacing: 20) {
                Text(copy.confirmDeleteRunTitle)
                    .font(.system(size: 28, weight: .bold))

                Text(copy.confirmDeleteRunMessage)
                    .font(.system(size: 15, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .opacity(0.8)

                VStack(spacing: 12) {
                    Button {
                        if let pendingDeleteRunID {
                            viewModel.deleteRun(id: pendingDeleteRunID)
                        }
                        withAnimation(.easeInOut(duration: 0.15)) {
                            self.pendingDeleteRunID = nil
                        }
                    } label: {
                        Text(copy.confirmYes)
                            .font(.system(size: 17, weight: .bold))
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
                        withAnimation(.easeInOut(duration: 0.15)) { pendingDeleteRunID = nil }
                    } label: {
                        Text(copy.confirmNo)
                            .font(.system(size: 17, weight: .bold))
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

    private var phaseTimeline: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(viewModel.phases.enumerated()), id: \.element.id) { index, phase in
                        phaseCard(for: phase, index: index)
                            .id(index)
                    }
                }
                .padding(.horizontal, 2)
            }
            .frame(height: 86)
            .onChange(of: viewModel.currentPhaseIndex) { _, newIndex in
                withAnimation(.easeInOut(duration: 0.25)) {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
        }
    }

    private func phaseCard(for timedPhase: TimedProcessPhase, index: Int) -> some View {
        let isCurrentPhase = index == viewModel.currentPhaseIndex

        return VStack(alignment: .leading, spacing: 8) {
            Text("\(index + 1). \(copy.phaseTitle(timedPhase.phase))")
                .font(.system(size: 18, weight: .bold))
                .lineLimit(1)

            Text(durationText(for: timedPhase.duration))
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .lineLimit(1)
        }
        .foregroundStyle(DarkroomPalette.red)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(width: 174, height: 76, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(DarkroomPalette.red, lineWidth: isCurrentPhase ? 3 : 1)
        )
        .accessibilityElement(children: .combine)
    }

    private var phaseHeader: some View {
        VStack(spacing: 8) {
            if let phase = viewModel.currentPhase {
                Text(copy.phaseTitle(phase.phase).uppercased())
                    .font(.system(size: 34, weight: .bold))
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var statusText: some View {
        switch viewModel.state {
        case .idle:
            Text(copy.ready)
                .font(.system(size: 30, weight: .bold))
        case .running:
            Text(copy.running)
                .font(.system(size: 30, weight: .bold))
        case .paused:
            Text(copy.paused)
                .font(.system(size: 30, weight: .bold))
        case .finished:
            Text(copy.complete)
                .font(.system(size: 30, weight: .bold))
        }
    }

    private var controlButtons: some View {
        HStack {
            Button {
                handleSecondaryButtonTap()
            } label: {
                controlButtonLabel(secondaryButtonTitle, isDisabled: isSecondaryButtonDisabled)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(secondaryButtonTitle)
            .disabled(isSecondaryButtonDisabled)

            Spacer(minLength: 40)

            Button {
                viewModel.startOrPause()
            } label: {
                controlButtonLabel(startPauseTitle, isDisabled: !viewModel.hasRuns)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(startPauseTitle)
            .disabled(!viewModel.hasRuns)
        }
        .padding(.horizontal, 6)
    }

    private func controlButtonLabel(_ title: String, isDisabled: Bool = false) -> some View {
        Text(title)
            .font(.system(size: 24, weight: .bold))
            .foregroundStyle(DarkroomPalette.red.opacity(isDisabled ? 0.35 : 1))
            .frame(width: 124, height: 124)
            .overlay(
                Circle()
                    .stroke(DarkroomPalette.red.opacity(isDisabled ? 0.35 : 1), lineWidth: 3)
            )
    }

    private var startPauseTitle: String {
        switch viewModel.state {
        case .running:
            return copy.pause
        case .paused:
            return copy.resume
        case .finished, .idle:
            return copy.start
        }
    }

    private var secondaryButtonTitle: String {
        if !viewModel.hasRuns {
            return copy.setup
        }

        switch viewModel.state {
        case .paused:
            return copy.reset
        case .idle, .running, .finished:
            return copy.setup
        }
    }

    private var isSecondaryButtonDisabled: Bool {
        viewModel.hasRuns && viewModel.state == .running && secondaryButtonTitle == copy.setup
    }

    private func handleSecondaryButtonTap() {
        if !viewModel.hasRuns {
            navigationPath.append(.setup)
            return
        }

        switch viewModel.state {
        case .paused:
            viewModel.reset()
        case .idle, .finished:
            navigationPath.append(.setup)
        case .running:
            break
        }
    }

    private var accessibilityTimerLabel: String {
        guard let phase = viewModel.currentPhase else {
            return copy.controlsHint
        }
        return "\(copy.phaseTitle(phase.phase)), \(viewModel.formattedRemainingTime)"
    }

    private func timerFontSize(for size: CGSize) -> CGFloat {
        min(size.width * 0.24, size.height * 0.22)
    }

    private func durationText(for duration: TimeInterval) -> String {
        let totalSeconds = max(0, Int(duration.rounded()))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d min", minutes, seconds)
    }

    private func runStatusText(for run: TimerViewModel.PaperRun) -> String {
        switch run.state {
        case .idle:
            return copy.ready
        case .running:
            return durationText(for: run.remainingTime).replacingOccurrences(of: " min", with: "")
        case .paused:
            return copy.paused
        case .finished:
            return copy.done
        }
    }
}

#Preview {
    DarkroomTimerView()
}

#if canImport(UIKit)
/// Umožní „swipe zleva doprava" (interaktivní pop) i když je systémový
/// navigation bar skrytý – stejné chování jako v systémové aplikaci Nastavení.
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}
#endif
