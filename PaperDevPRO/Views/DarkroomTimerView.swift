import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

public enum DarkroomPalette {
    public static let black = Color(red: 0, green: 0, blue: 0)
    public static let red = Color(red: 1, green: 0, blue: 0)
}

@MainActor
public struct DarkroomTimerView: View {
    @StateObject private var viewModel: TimerViewModel
    @State private var isShowingSetup = false

    public init(session: DevelopmentSession = MockDarkroomDatabase.defaultSession) {
        _viewModel = StateObject(wrappedValue: TimerViewModel(session: session))
    }

    public init(viewModel: TimerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                DarkroomPalette.black
                    .ignoresSafeArea()

                VStack(spacing: 22) {
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

                    controlButtons
                }
                .foregroundStyle(DarkroomPalette.red)
                .multilineTextAlignment(.center)
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(DarkroomPalette.black)
        .preferredColorScheme(.dark)
        .statusBar(hidden: true)
        .onAppear {
            setIdleTimerDisabled(true)
        }
        .onDisappear {
            setIdleTimerDisabled(false)
        }
        .sheet(isPresented: $isShowingSetup) {
            SetupView(initialSession: viewModel.session) { session in
                viewModel.configure(session: session)
            }
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
            Text("\(index + 1). \(displayTitle(for: timedPhase.phase))")
                .font(.system(size: 18, weight: .bold, design: .rounded))
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
            Text(displayTitle(for: viewModel.currentPhase.phase).uppercased())
                .font(.system(size: 34, weight: .bold, design: .rounded))
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var statusText: some View {
        switch viewModel.state {
        case .idle:
            Text("READY")
                .font(.system(size: 30, weight: .bold, design: .rounded))
        case .running:
            Text("RUNNING")
                .font(.system(size: 30, weight: .bold, design: .rounded))
        case .paused:
            Text("PAUSED")
                .font(.system(size: 30, weight: .bold, design: .rounded))
        case .finished:
            Text("COMPLETE")
                .font(.system(size: 30, weight: .bold, design: .rounded))
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
                controlButtonLabel(startPauseTitle)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(startPauseTitle)
        }
        .padding(.horizontal, 6)
    }

    private func controlButtonLabel(_ title: String, isDisabled: Bool = false) -> some View {
        Text(title)
            .font(.system(size: 24, weight: .bold, design: .rounded))
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
            return "PAUSE"
        case .paused:
            return "RESUME"
        case .finished:
            return "START"
        case .idle:
            return "START"
        }
    }

    private var secondaryButtonTitle: String {
        switch viewModel.state {
        case .paused:
            return "RESET"
        case .idle, .running, .finished:
            return "SETUP"
        }
    }

    private var isSecondaryButtonDisabled: Bool {
        viewModel.state == .running
    }

    private func handleSecondaryButtonTap() {
        switch viewModel.state {
        case .paused:
            viewModel.reset()
        case .idle, .finished:
            isShowingSetup = true
        case .running:
            break
        }
    }

    private var accessibilityTimerLabel: String {
        "\(displayTitle(for: viewModel.currentPhase.phase)), \(viewModel.formattedRemainingTime) remaining"
    }

    private func timerFontSize(for size: CGSize) -> CGFloat {
        min(size.width * 0.24, size.height * 0.22)
    }

    private func displayTitle(for phase: ProcessPhase) -> String {
        switch phase {
        case .developer:
            return "Vývojka"
        case .transferToStopBath:
            return "Přendání"
        case .stopBath:
            return "Přerušovač"
        case .transferToFixer:
            return "Přendání"
        case .fixer:
            return "Ustalovač"
        case .transferToWash:
            return "Přendání"
        case .wash:
            return "Praní"
        }
    }

    private func durationText(for duration: TimeInterval) -> String {
        let totalSeconds = max(0, Int(duration.rounded()))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d min", minutes, seconds)
    }

    private func setIdleTimerDisabled(_ isDisabled: Bool) {
        #if canImport(UIKit)
        UIApplication.shared.isIdleTimerDisabled = isDisabled
        #endif
    }
}

#Preview {
    DarkroomTimerView()
}
