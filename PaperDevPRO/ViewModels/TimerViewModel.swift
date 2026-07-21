import Combine
import Foundation

#if canImport(AudioToolbox)
import AudioToolbox
#endif

#if canImport(UIKit)
import UIKit
#endif

@MainActor
public final class TimerViewModel: ObservableObject {
    public enum TimerState: Equatable {
        case idle
        case running
        case paused
        case finished
    }

    public struct PaperRun: Identifiable, Equatable {
        public let id: UUID
        public let number: Int
        public var session: DevelopmentSession
        public var phases: [TimedProcessPhase]
        public var currentPhaseIndex: Int
        public var remainingTime: TimeInterval
        public var state: TimerState
        fileprivate var lastTickDate: Date?
        fileprivate var lastWarningSecond: Int?
        fileprivate var usageWasRecorded: Bool

        public var currentPhase: TimedProcessPhase {
            phases[currentPhaseIndex]
        }
    }

    @Published public private(set) var session: DevelopmentSession
    @Published public private(set) var runs: [PaperRun]
    @Published public private(set) var selectedRunID: UUID

    private var timerTask: Task<Void, Never>?
    private var nextRunNumber = 1

    public var selectedRun: PaperRun {
        runs.first { $0.id == selectedRunID } ?? runs[0]
    }

    public var phases: [TimedProcessPhase] {
        selectedRun.phases
    }

    public var currentPhaseIndex: Int {
        selectedRun.currentPhaseIndex
    }

    public var remainingTime: TimeInterval {
        selectedRun.remainingTime
    }

    public var state: TimerState {
        selectedRun.state
    }

    public var currentPhase: TimedProcessPhase {
        selectedRun.currentPhase
    }

    public var hasRunningRuns: Bool {
        runs.contains { $0.state == .running }
    }

    public var progress: Double {
        guard currentPhase.duration > 0 else { return 0 }
        return 1 - (remainingTime / currentPhase.duration)
    }

    public var formattedRemainingTime: String {
        formatTime(remainingTime)
    }

    public var nextPhaseTitle: String? {
        let nextIndex = currentPhaseIndex + 1
        guard phases.indices.contains(nextIndex) else { return nil }
        return phases[nextIndex].phase.title
    }

    public init(session: DevelopmentSession = MockDarkroomDatabase.defaultSession) {
        self.session = session
        let initialRun = Self.makeRun(number: 1, session: session)
        self.runs = [initialRun]
        self.selectedRunID = initialRun.id
        self.nextRunNumber = 2
    }

    deinit {
        timerTask?.cancel()
    }

    public func configure(session: DevelopmentSession) {
        stopTimerLoop()
        self.session = session
        let configuredRun = Self.makeRun(number: 1, session: session)
        self.runs = [configuredRun]
        self.selectedRunID = configuredRun.id
        self.nextRunNumber = 2
        setIdleTimerDisabled(false)
    }

    public func configureSelectedRun(session: DevelopmentSession) {
        self.session = session

        mutateSelectedRun { run in
            run.session = session
            run.phases = session.resolvedPhases()
            run.currentPhaseIndex = 0
            run.remainingTime = run.phases[0].duration
            run.state = .idle
            run.lastTickDate = nil
            run.lastWarningSecond = nil
            run.usageWasRecorded = false
        }

        refreshTimerLoop()
    }

    public func resetProject() {
        configure(session: MockDarkroomDatabase.defaultSession)
    }

    public func addPaperRun() {
        let run = Self.makeRun(number: nextRunNumber, session: session, state: .idle)
        nextRunNumber += 1
        runs.append(run)
        selectedRunID = run.id
    }

    public func selectRun(id: UUID) {
        guard runs.contains(where: { $0.id == id }) else { return }
        selectedRunID = id
    }

    public func startOrPause() {
        mutateSelectedRun { run in
            switch run.state {
            case .idle, .paused:
                run.state = .running
                run.lastTickDate = Date()
            case .running:
                run.state = .paused
                run.lastTickDate = nil
            case .finished:
                reset(run: &run)
                run.state = .running
                run.lastTickDate = Date()
            }
        }

        refreshTimerLoop()
    }

    public func start() {
        mutateSelectedRun { run in
            guard run.state != .running else { return }
            run.state = .running
            run.lastTickDate = Date()
        }

        refreshTimerLoop()
    }

    public func pause() {
        mutateSelectedRun { run in
            guard run.state == .running else { return }
            run.state = .paused
            run.lastTickDate = nil
        }

        refreshTimerLoop()
    }

    public func reset() {
        mutateSelectedRun { run in
            reset(run: &run)
        }

        refreshTimerLoop()
    }

    public func skipToNextPhase() {
        guard let index = runs.firstIndex(where: { $0.id == selectedRunID }) else { return }
        advanceToNextPhase(for: index)
        refreshTimerLoop()
    }

    private static func makeRun(
        number: Int,
        session: DevelopmentSession,
        state: TimerState = .idle
    ) -> PaperRun {
        let phases = session.resolvedPhases()

        return PaperRun(
            id: UUID(),
            number: number,
            session: session,
            phases: phases,
            currentPhaseIndex: 0,
            remainingTime: phases[0].duration,
            state: state,
            lastTickDate: state == .running ? Date() : nil,
            lastWarningSecond: nil,
            usageWasRecorded: false
        )
    }

    private func mutateSelectedRun(_ mutation: (inout PaperRun) -> Void) {
        guard let index = runs.firstIndex(where: { $0.id == selectedRunID }) else { return }
        mutation(&runs[index])
    }

    private func reset(run: inout PaperRun) {
        run.currentPhaseIndex = 0
        run.remainingTime = run.phases[0].duration
        run.state = .idle
        run.lastTickDate = nil
        run.lastWarningSecond = nil
        run.usageWasRecorded = false
    }

    private func startTimerLoop() {
        guard timerTask == nil else { return }

        timerTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 250_000_000)
                self?.tick()
            }
        }
    }

    private func stopTimerLoop() {
        timerTask?.cancel()
        timerTask = nil

        for index in runs.indices {
            runs[index].lastTickDate = nil
        }
    }

    private func refreshTimerLoop() {
        if hasRunningRuns {
            setIdleTimerDisabled(true)
            startTimerLoop()
        } else {
            stopTimerLoop()
            setIdleTimerDisabled(false)
        }
    }

    private func tick() {
        let now = Date()

        for index in runs.indices {
            guard runs[index].state == .running else { continue }

            let elapsed = now.timeIntervalSince(runs[index].lastTickDate ?? now)
            runs[index].lastTickDate = now
            runs[index].remainingTime -= elapsed

            if runs[index].remainingTime <= 0 {
                advanceToNextPhase(for: index)
            } else {
                triggerFinalSecondsWarningIfNeeded(for: index)
            }
        }

        refreshTimerLoop()
    }

    private func advanceToNextPhase(for index: Int) {
        runs[index].lastWarningSecond = nil

        guard runs[index].currentPhaseIndex + 1 < runs[index].phases.count else {
            runs[index].remainingTime = 0
            runs[index].state = .finished
            runs[index].lastTickDate = nil

            if !runs[index].usageWasRecorded {
                ChemicalUsageStore.shared.recordCompletedCycle(for: runs[index].session)
                runs[index].usageWasRecorded = true
            }

            triggerCompletionFeedback()
            return
        }

        runs[index].currentPhaseIndex += 1
        runs[index].remainingTime = runs[index].phases[runs[index].currentPhaseIndex].duration
        runs[index].lastTickDate = Date()
        triggerPhaseChangeFeedback()
    }

    private func triggerFinalSecondsWarningIfNeeded(for index: Int) {
        let warningSecond = Int(ceil(runs[index].remainingTime))
        guard (1...5).contains(warningSecond), warningSecond != runs[index].lastWarningSecond else {
            return
        }

        runs[index].lastWarningSecond = warningSecond
        triggerWarningFeedback()
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = max(0, Int(ceil(time)))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func triggerWarningFeedback() {
        #if canImport(AudioToolbox)
        AudioServicesPlaySystemSound(1057)
        #endif

        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
        #endif
    }

    private func triggerPhaseChangeFeedback() {
        #if canImport(AudioToolbox)
        AudioServicesPlaySystemSound(1113)
        #endif

        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    private func triggerCompletionFeedback() {
        #if canImport(AudioToolbox)
        AudioServicesPlaySystemSound(1025)
        #endif

        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    private func setIdleTimerDisabled(_ isDisabled: Bool) {
        #if canImport(UIKit)
        UIApplication.shared.isIdleTimerDisabled = isDisabled
        #endif
    }
}
