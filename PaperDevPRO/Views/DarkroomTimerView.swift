import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

public enum DarkroomPalette {
    public static let black = Color(red: 0, green: 0, blue: 0)
    public static let red = Color(red: 1, green: 0, blue: 0)
}

/// Point sizes that follow Dynamic Type, capped so the darkroom layout does not explode.
/// Built as a `Font` (not a custom `ViewModifier`) so Setup's already-huge view type
/// does not grow another generic wrapper around every label.
extension Font {
    static func darkroom(
        _ size: CGFloat,
        weight: Font.Weight = .regular,
        design: Font.Design = .default,
        relativeTo textStyle: Font.TextStyle = .body
    ) -> Font {
        #if canImport(UIKit)
        let metrics = UIFontMetrics(forTextStyle: textStyle.uiTextStyle)
        let base: UIFont
        if design == .monospaced {
            base = UIFont.monospacedDigitSystemFont(ofSize: size, weight: weight.uiWeight)
        } else {
            base = UIFont.systemFont(ofSize: size, weight: weight.uiWeight)
        }
        return Font(metrics.scaledFont(for: base, maximumPointSize: size * 1.6))
        #else
        return .system(size: size, weight: weight, design: design)
        #endif
    }
}

private struct DarkroomFrameModifier: ViewModifier {
    @ScaledMetric var width: CGFloat
    @ScaledMetric var height: CGFloat

    init(width: CGFloat, height: CGFloat) {
        _width = ScaledMetric(wrappedValue: width, relativeTo: .body)
        _height = ScaledMetric(wrappedValue: height, relativeTo: .body)
    }

    func body(content: Content) -> some View {
        content.frame(width: width, height: height)
    }
}

extension View {
    func darkroomFont(
        _ size: CGFloat,
        weight: Font.Weight = .regular,
        design: Font.Design = .default,
        relativeTo textStyle: Font.TextStyle = .body
    ) -> some View {
        font(.darkroom(size, weight: weight, design: design, relativeTo: textStyle))
    }

    func darkroomFrame(width: CGFloat, height: CGFloat) -> some View {
        modifier(DarkroomFrameModifier(width: width, height: height))
    }
}

#if canImport(UIKit)
private extension Font.TextStyle {
    var uiTextStyle: UIFont.TextStyle {
        switch self {
        case .largeTitle: return .largeTitle
        case .title: return .title1
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .body: return .body
        case .callout: return .callout
        case .footnote: return .footnote
        case .caption: return .caption1
        case .caption2: return .caption2
        @unknown default: return .body
        }
    }
}

private extension Font.Weight {
    var uiWeight: UIFont.Weight {
        switch self {
        case .ultraLight: return .ultraLight
        case .thin: return .thin
        case .light: return .light
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        case .heavy: return .heavy
        case .black: return .black
        default: return .regular
        }
    }
}
#endif

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
    @Environment(\.scenePhase) private var scenePhase

    public init(session: DevelopmentSession? = nil) {
        let resolvedSession = session ?? DarkroomCatalog.configuredDefaultSession
        _viewModel = StateObject(wrappedValue: TimerViewModel(session: resolvedSession))
    }

    private var copy: AppCopy { settingsStore.copy }

    public var body: some View {
        NavigationStack(path: $navigationPath) {
            timerContent
                .navigationDestination(for: SetupRoute.self) { route in
                    destinationView(for: route)
                        .navigationBarBackButtonHidden(true)
                        .toolbar(.hidden, for: .navigationBar)
                        .background(swipeBackEnabler)
                }
        }
        .tint(DarkroomPalette.red)
    }

    @ViewBuilder
    private var swipeBackEnabler: some View {
        #if canImport(UIKit)
        InteractivePopGestureEnabler()
            .frame(width: 0, height: 0)
            .accessibilityHidden(true)
        #else
        EmptyView()
        #endif
    }

    @ViewBuilder
    private func destinationView(for route: SetupRoute) -> some View {
        switch route {
        case .setup:
            SetupView(
                initialSession: viewModel.session,
                isEditingFinishedRun: viewModel.state == .finished,
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
                            .darkroomFont(timerFontSize(for: geometry.size), weight: .bold, design: .monospaced, relativeTo: .largeTitle)
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
                            Text(AppInfo.displayName)
                                .darkroomFont(34, weight: .bold)
                                .foregroundStyle(DarkroomPalette.red)

                            Text(copy.safelightWarning)
                                .darkroomFont(15, weight: .semibold)
                                .foregroundStyle(DarkroomPalette.red.opacity(0.85))
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 8)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(AppInfo.displayName). \(copy.safelightWarning)")

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
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                viewModel.applicationDidBecomeActive()
            case .background, .inactive:
                viewModel.applicationDidEnterBackground()
            @unknown default:
                break
            }
        }
    }

    private var paperRunTimeline: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Text("+")
                    .darkroomFont(32, weight: .bold)
                    .foregroundStyle(DarkroomPalette.red)
                    .darkroomFrame(width: 58, height: 58)
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
        .frame(minHeight: 70)
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
            .darkroomFont(22, weight: .semibold)
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
                .darkroomFont(17, weight: .bold)

            Text(runStatusText(for: run))
                .darkroomFont(14, weight: .bold, design: .monospaced)
                .lineLimit(1)
        }
        .foregroundStyle(DarkroomPalette.red)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
            .frame(minWidth: 132, minHeight: 58, alignment: .leading)
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
                    .darkroomFont(28, weight: .bold)

                Text(copy.confirmDeleteRunMessage)
                    .darkroomFont(15, weight: .semibold)
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
                        withAnimation(.easeInOut(duration: 0.15)) { pendingDeleteRunID = nil }
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
                .darkroomFont(18, weight: .bold)
                .lineLimit(1)

            Text(durationText(for: timedPhase.duration))
                .darkroomFont(20, weight: .bold, design: .monospaced)
                .lineLimit(1)
        }
        .foregroundStyle(DarkroomPalette.red)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .padding(.vertical, 8)
            .frame(minWidth: 174, minHeight: 76, alignment: .leading)
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
                    .darkroomFont(34, weight: .bold)
            }
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var statusText: some View {
        switch viewModel.state {
        case .idle:
            Text(copy.ready)
                .darkroomFont(30, weight: .bold)
        case .running:
            Text(copy.running)
                .darkroomFont(30, weight: .bold)
        case .paused:
            Text(copy.paused)
                .darkroomFont(30, weight: .bold)
        case .finished:
            Text(copy.complete)
                .darkroomFont(30, weight: .bold)
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
                controlButtonLabel(startPauseTitle, isDisabled: viewModel.isStartPauseDisabled)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(startPauseTitle)
            .disabled(viewModel.isStartPauseDisabled)
        }
        .padding(.horizontal, 6)
    }

    private func controlButtonLabel(_ title: String, isDisabled: Bool = false) -> some View {
        Text(title)
            .darkroomFont(24, weight: .bold)
            .foregroundStyle(DarkroomPalette.red.opacity(isDisabled ? 0.35 : 1))
            .darkroomFrame(width: 124, height: 124)
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
/// Umožní „swipe zleva doprava" (interaktivní pop) i když je systémový navigation bar
/// skrytý. Dřív to řešila kategorie nad `UINavigationController`, která přepisovala
/// `viewDidLoad` a měnila delegáta gesta globálně pro celou aplikaci; tady se to týká
/// jen navigation controlleru, ve kterém je vložená tato jedna obrazovka.
struct InteractivePopGestureEnabler: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIViewController(context: Context) -> UIViewController {
        GestureAttachingController(coordinator: context.coordinator)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        weak var navigationController: UINavigationController?

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            (navigationController?.viewControllers.count ?? 0) > 1
        }
    }

    private final class GestureAttachingController: UIViewController {
        private let coordinator: Coordinator

        init(coordinator: Coordinator) {
            self.coordinator = coordinator
            super.init(nibName: nil, bundle: nil)
            view.isUserInteractionEnabled = false
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)

            guard let navigationController = parent?.navigationController else { return }
            coordinator.navigationController = navigationController
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
            navigationController.interactivePopGestureRecognizer?.delegate = coordinator
        }
    }
}
#endif
