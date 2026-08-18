import Combine
import Foundation

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
        public var isTestStrip: Bool
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
    @Published public private(set) var selectedRunID: UUID?

    private var timerTask: Task<Void, Never>?
    private var nextPaperNumber = 1
    private var nextTestStripNumber = 1

    public var hasRuns: Bool { !runs.isEmpty }

    public var selectedRun: PaperRun? {
        guard let selectedRunID else { return nil }
        return runs.first { $0.id == selectedRunID }
    }

    public var phases: [TimedProcessPhase] {
        selectedRun?.phases ?? []
    }

    public var currentPhaseIndex: Int {
        selectedRun?.currentPhaseIndex ?? 0
    }

    public var remainingTime: TimeInterval {
        selectedRun?.remainingTime ?? 0
    }

    public var state: TimerState {
        selectedRun?.state ?? .idle
    }

    public var currentPhase: TimedProcessPhase? {
        guard let selectedRun,
              selectedRun.phases.indices.contains(selectedRun.currentPhaseIndex) else {
            return nil
        }
        return selectedRun.phases[selectedRun.currentPhaseIndex]
    }

    public var hasRunningRuns: Bool {
        runs.contains { $0.state == .running }
    }

    public var formattedRemainingTime: String {
        guard hasRuns else { return "--:--" }
        return formatTime(remainingTime)
    }

    public var nextPhase: ProcessPhase? {
        let nextIndex = currentPhaseIndex + 1
        guard phases.indices.contains(nextIndex) else { return nil }
        return phases[nextIndex].phase
    }

    /// A finished run has to be reset before it can run again, so START stays dimmed.
    public var isStartPauseDisabled: Bool {
        !hasRuns || state == .finished
    }

    public init(session: DevelopmentSession? = nil) {
        let resolvedSession = session ?? DarkroomCatalog.configuredDefaultSession
        self.session = resolvedSession
        self.runs = []
        self.selectedRunID = nil
        self.nextPaperNumber = 1
        self.nextTestStripNumber = 1
    }

    deinit {
        timerTask?.cancel()
    }

    public func configure(session: DevelopmentSession) {
        stopTimerLoop()
        self.session = session
        self.runs = []
        self.selectedRunID = nil
        self.nextPaperNumber = 1
        self.nextTestStripNumber = 1
        applyKeepScreenOn()
    }

    public func configureSelectedRun(session: DevelopmentSession) {
        guard session != self.session else { return }

        self.session = session

        guard hasRuns else {
            refreshTimerLoop()
            return
        }

        mutateSelectedRun { run in
            let runSession = run.isTestStrip ? session.testStripRunSession() : session
            let previousSession = run.session
            let wasFinished = run.state == .finished

            run.session = runSession
            run.phases = runSession.resolvedPhases()
            run.lastTickDate = nil
            run.lastWarningSecond = nil

            // A finished sheet stays finished – it already went through the baths.
            // Editing its setup corrects the record (e.g. the size was wrong) instead
            // of counting the chemistry a second time.
            if wasFinished {
                run.currentPhaseIndex = max(0, run.phases.count - 1)
                run.remainingTime = 0

                if run.usageWasRecorded {
                    ChemicalUsageStore.shared.reviseCompletedCycle(
                        from: previousSession,
                        to: runSession
                    )
                }
            } else {
                run.currentPhaseIndex = 0
                run.remainingTime = run.phases[0].duration
                run.state = .idle
                run.usageWasRecorded = false
            }
        }

        refreshTimerLoop()
    }

    public func resetProject() {
        configure(session: DarkroomCatalog.configuredDefaultSession)
    }

    public func addPaperRun() {
        let run = Self.makeRun(number: nextPaperNumber, session: session, isTestStrip: false)
        nextPaperNumber += 1
        runs.append(run)
        selectedRunID = run.id
    }

    public func addTestStripRun() {
        let run = Self.makeRun(
            number: nextTestStripNumber,
            session: session.testStripRunSession(),
            isTestStrip: true
        )
        nextTestStripNumber += 1
        runs.append(run)
        selectedRunID = run.id
    }

    public func deleteRun(id: UUID) {
        guard let index = runs.firstIndex(where: { $0.id == id }) else { return }

        let wasSelected = runs[index].id == selectedRunID
        if runs[index].state == .running {
            runs[index].state = .idle
            runs[index].lastTickDate = nil
        }
        runs.remove(at: index)

        if wasSelected {
            selectedRunID = runs.last?.id
        }

        refreshTimerLoop()
    }

    public func selectRun(id: UUID) {
        guard runs.contains(where: { $0.id == id }) else { return }
        selectedRunID = id
    }

    public func startOrPause() {
        guard hasRuns, state != .finished else { return }

        RunCompletionNotifier.shared.prepareAuthorization()
        DarkroomFeedback.shared.prepare()

        mutateSelectedRun { run in
            switch run.state {
            case .idle, .paused:
                run.state = .running
                run.lastTickDate = Date()
            case .running:
                run.state = .paused
                run.lastTickDate = nil
            case .finished:
                break
            }
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

    /// Going to the background: the process keeps running against the wall clock, so
    /// hand the finish time over to a local notification. Nothing else makes noise.
    public func applicationDidEnterBackground() {
        let now = Date()
        let completions = runs.compactMap { run -> RunCompletionNotifier.PendingCompletion? in
            guard let date = expectedCompletionDate(for: run, from: now) else { return nil }
            return RunCompletionNotifier.PendingCompletion(
                id: run.id,
                title: runTitle(for: run),
                date: date
            )
        }

        let settings = DarkroomSettingsStore.shared
        RunCompletionNotifier.shared.schedule(
            completions,
            body: settings.copy.notificationRunCompleteBody,
            playSound: settings.isSoundEnabled
        )
    }

    /// Back in front: drop the pending notifications and catch the timers up to now.
    public func applicationDidBecomeActive() {
        RunCompletionNotifier.shared.cancelAll()
        tick()
    }

    private func expectedCompletionDate(for run: PaperRun, from now: Date) -> Date? {
        guard run.state == .running else { return nil }

        let laterPhases = run.phases
            .dropFirst(run.currentPhaseIndex + 1)
            .reduce(0) { $0 + $1.duration }

        return now.addingTimeInterval(run.remainingTime + laterPhases)
    }

    private func runTitle(for run: PaperRun) -> String {
        let copy = DarkroomSettingsStore.shared.copy
        return "\(run.isTestStrip ? copy.testStrip : copy.paper) \(run.number)"
    }

    private static func makeRun(
        number: Int,
        session: DevelopmentSession,
        isTestStrip: Bool = false,
        state: TimerState = .idle
    ) -> PaperRun {
        let phases = session.resolvedPhases()

        return PaperRun(
            id: UUID(),
            number: number,
            isTestStrip: isTestStrip,
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
        guard let selectedRunID,
              let index = runs.firstIndex(where: { $0.id == selectedRunID }) else { return }
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
            applyKeepScreenOn()
            startTimerLoop()
        } else {
            stopTimerLoop()
            applyKeepScreenOn()
        }
    }

    private func tick() {
        let now = Date()

        for index in runs.indices where runs[index].state == .running {
            advance(runIndex: index, to: now)
        }

        // Only touch the run loop / idle timer when something actually stopped,
        // instead of four times per second.
        if !hasRunningRuns {
            refreshTimerLoop()
        }
    }

    /// Consumes the whole elapsed interval, phase by phase. A single tick can cover
    /// minutes (screen locked, app suspended), so the overflow has to roll into the
    /// following phases instead of being thrown away.
    #if DEBUG
    /// Same catch-up path a tick takes, with an explicit "now" so the wall clock
    /// does not have to be waited out in tests.
    func catchUp(to date: Date) {
        for index in runs.indices where runs[index].state == .running {
            advance(runIndex: index, to: date)
        }

        if !hasRunningRuns {
            refreshTimerLoop()
        }
    }
    #endif

    private func advance(runIndex index: Int, to now: Date) {
        var elapsed = now.timeIntervalSince(runs[index].lastTickDate ?? now)
        runs[index].lastTickDate = now
        guard elapsed > 0 else { return }

        var didCrossPhase = false

        while elapsed > 0, runs[index].state == .running {
            if runs[index].remainingTime > elapsed {
                runs[index].remainingTime -= elapsed
                elapsed = 0
            } else {
                elapsed -= runs[index].remainingTime
                runs[index].remainingTime = 0
                advanceToNextPhase(for: index, at: now, shouldNotify: false)
                didCrossPhase = true
            }
        }

        guard isSelectedRun(at: index) else { return }

        // One sound per tick even if several phases elapsed at once.
        if runs[index].state == .finished {
            if didCrossPhase {
                triggerCompletionFeedback()
            }
        } else if didCrossPhase {
            triggerPhaseChangeFeedback()
        } else {
            triggerFinalSecondsWarningIfNeeded(for: index)
        }
    }

    private func advanceToNextPhase(for index: Int, at now: Date, shouldNotify: Bool = true) {
        runs[index].lastWarningSecond = nil

        guard runs[index].currentPhaseIndex + 1 < runs[index].phases.count else {
            runs[index].remainingTime = 0
            runs[index].state = .finished
            runs[index].lastTickDate = nil

            if !runs[index].usageWasRecorded {
                ChemicalUsageStore.shared.recordCompletedCycle(for: runs[index].session)
                runs[index].usageWasRecorded = true
            }

            if shouldNotify, isSelectedRun(at: index) {
                triggerCompletionFeedback()
            }
            return
        }

        runs[index].currentPhaseIndex += 1
        runs[index].remainingTime = runs[index].phases[runs[index].currentPhaseIndex].duration
        runs[index].lastTickDate = now

        if shouldNotify, isSelectedRun(at: index) {
            triggerPhaseChangeFeedback()
        }
    }

    private func triggerFinalSecondsWarningIfNeeded(for index: Int) {
        guard isSelectedRun(at: index) else { return }

        let warningSecond = Int(ceil(runs[index].remainingTime))
        guard (1...5).contains(warningSecond), warningSecond != runs[index].lastWarningSecond else {
            return
        }

        runs[index].lastWarningSecond = warningSecond
        triggerWarningFeedback()
    }

    private func isSelectedRun(at index: Int) -> Bool {
        runs.indices.contains(index) && runs[index].id == selectedRunID
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = max(0, Int(ceil(time)))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func triggerWarningFeedback() {
        playFeedback(.warning)
    }

    private func triggerPhaseChangeFeedback() {
        playFeedback(.phaseChange)
    }

    private func triggerCompletionFeedback() {
        playFeedback(.completion)
    }

    private func playFeedback(_ cue: DarkroomFeedback.Cue) {
        let settings = DarkroomSettingsStore.shared
        DarkroomFeedback.shared.play(
            cue,
            sound: settings.isSoundEnabled,
            haptics: settings.isHapticsEnabled
        )
    }

    private func applyKeepScreenOn() {
        DarkroomSettingsStore.shared.applyKeepScreenOn()
    }
}
