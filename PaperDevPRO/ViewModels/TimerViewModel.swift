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

    @Published public private(set) var session: DevelopmentSession
    @Published public private(set) var phases: [TimedProcessPhase]
    @Published public private(set) var currentPhaseIndex: Int = 0
    @Published public private(set) var remainingTime: TimeInterval
    @Published public private(set) var state: TimerState = .idle

    private var timerTask: Task<Void, Never>?
    private var lastTickDate: Date?
    private var lastWarningSecond: Int?

    public var currentPhase: TimedProcessPhase {
        phases[currentPhaseIndex]
    }

    public var progress: Double {
        guard currentPhase.duration > 0 else { return 0 }
        return 1 - (remainingTime / currentPhase.duration)
    }

    public var formattedRemainingTime: String {
        let totalSeconds = max(0, Int(ceil(remainingTime)))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    public var nextPhaseTitle: String? {
        let nextIndex = currentPhaseIndex + 1
        guard phases.indices.contains(nextIndex) else { return nil }
        return phases[nextIndex].phase.title
    }

    public init(session: DevelopmentSession = MockDarkroomDatabase.defaultSession) {
        let resolvedPhases = session.resolvedPhases()
        self.session = session
        self.phases = resolvedPhases
        self.remainingTime = resolvedPhases[0].duration
    }

    deinit {
        timerTask?.cancel()
    }

    public func configure(session: DevelopmentSession) {
        stopTimerLoop()
        self.session = session
        self.phases = session.resolvedPhases()
        self.currentPhaseIndex = 0
        self.remainingTime = phases[0].duration
        self.state = .idle
        self.lastWarningSecond = nil
        setIdleTimerDisabled(false)
    }

    public func startOrPause() {
        switch state {
        case .idle, .paused:
            start()
        case .running:
            pause()
        case .finished:
            reset()
            start()
        }
    }

    public func start() {
        guard state != .running else { return }
        state = .running
        lastTickDate = Date()
        setIdleTimerDisabled(true)
        startTimerLoop()
    }

    public func pause() {
        guard state == .running else { return }
        state = .paused
        stopTimerLoop()
    }

    public func reset() {
        stopTimerLoop()
        currentPhaseIndex = 0
        remainingTime = phases[0].duration
        state = .idle
        lastWarningSecond = nil
        setIdleTimerDisabled(false)
    }

    public func skipToNextPhase() {
        advanceToNextPhase()
    }

    private func startTimerLoop() {
        stopTimerLoop()

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
        lastTickDate = nil
    }

    private func tick() {
        guard state == .running else { return }

        let now = Date()
        let elapsed = now.timeIntervalSince(lastTickDate ?? now)
        lastTickDate = now

        remainingTime -= elapsed

        if remainingTime <= 0 {
            advanceToNextPhase()
            return
        }

        triggerFinalSecondsWarningIfNeeded()
    }

    private func advanceToNextPhase() {
        lastWarningSecond = nil

        guard currentPhaseIndex + 1 < phases.count else {
            remainingTime = 0
            state = .finished
            stopTimerLoop()
            setIdleTimerDisabled(false)
            ChemicalUsageStore.shared.recordCompletedCycle(for: session)
            triggerCompletionFeedback()
            return
        }

        currentPhaseIndex += 1
        remainingTime = phases[currentPhaseIndex].duration
        lastTickDate = Date()
        triggerPhaseChangeFeedback()
    }

    private func triggerFinalSecondsWarningIfNeeded() {
        let warningSecond = Int(ceil(remainingTime))
        guard (1...5).contains(warningSecond), warningSecond != lastWarningSecond else {
            return
        }

        lastWarningSecond = warningSecond
        triggerWarningFeedback()
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
