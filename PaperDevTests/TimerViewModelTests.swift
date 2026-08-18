import XCTest
@testable import PaperDev

@MainActor
final class TimerViewModelTests: XCTestCase {
    private func makeViewModel() -> TimerViewModel {
        TimerViewModel(session: DarkroomCatalog.defaultSession)
    }

    func testAddingRunSelectsItAndArmsFirstPhase() {
        let viewModel = makeViewModel()
        XCTAssertTrue(viewModel.isStartPauseDisabled)

        viewModel.addPaperRun()

        XCTAssertEqual(viewModel.runs.count, 1)
        XCTAssertEqual(viewModel.selectedRunID, viewModel.runs.first?.id)
        XCTAssertEqual(viewModel.currentPhaseIndex, 0)
        XCTAssertEqual(viewModel.remainingTime, viewModel.phases.first?.duration)
        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertFalse(viewModel.isStartPauseDisabled)
    }

    /// A1: a tick can cover minutes (screen locked). The leftover has to roll into the
    /// following phases instead of parking the run at 0 s of the first one.
    func testCatchUpRollsOverIntoLaterPhases() throws {
        let viewModel = makeViewModel()
        viewModel.addPaperRun()

        let firstPhase = try XCTUnwrap(viewModel.phases.first)
        let secondPhase = viewModel.phases[1]
        let start = Date()
        viewModel.startOrPause()

        viewModel.catchUp(to: start.addingTimeInterval(firstPhase.duration + 2))

        XCTAssertEqual(viewModel.currentPhaseIndex, 1)
        XCTAssertEqual(viewModel.remainingTime, secondPhase.duration - 2, accuracy: 0.5)
        XCTAssertEqual(viewModel.state, .running)
    }

    func testCatchUpBeyondTheLastPhaseFinishesTheRunAndDisablesStart() {
        let viewModel = makeViewModel()
        viewModel.addPaperRun()

        let total = viewModel.phases.reduce(0) { $0 + $1.duration }
        let start = Date()
        viewModel.startOrPause()

        viewModel.catchUp(to: start.addingTimeInterval(total + 60))

        XCTAssertEqual(viewModel.state, .finished)
        XCTAssertEqual(viewModel.remainingTime, 0)
        XCTAssertEqual(viewModel.currentPhaseIndex, viewModel.phases.count - 1)
        // B12: a finished run must be reset before it can run again.
        XCTAssertTrue(viewModel.isStartPauseDisabled)

        viewModel.startOrPause()
        XCTAssertEqual(viewModel.state, .finished)

        viewModel.reset()
        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertEqual(viewModel.currentPhaseIndex, 0)
        XCTAssertFalse(viewModel.isStartPauseDisabled)
    }

    func testPausedRunDoesNotConsumeTime() throws {
        let viewModel = makeViewModel()
        viewModel.addPaperRun()

        let start = Date()
        viewModel.startOrPause()
        viewModel.catchUp(to: start.addingTimeInterval(5))
        viewModel.pause()

        let remainingWhenPaused = viewModel.remainingTime
        viewModel.catchUp(to: start.addingTimeInterval(500))

        XCTAssertEqual(viewModel.state, .paused)
        XCTAssertEqual(viewModel.remainingTime, remainingWhenPaused)
    }

    /// A2: several sheets run at the same time; only the selected one makes noise,
    /// but every running sheet has to keep counting down.
    func testParallelRunsAllAdvance() {
        let viewModel = makeViewModel()
        viewModel.addPaperRun()
        let first = viewModel.runs[0].id
        viewModel.startOrPause()

        viewModel.addTestStripRun()
        let second = viewModel.runs[1].id
        viewModel.startOrPause()

        let start = Date()
        viewModel.catchUp(to: start.addingTimeInterval(5))

        for run in viewModel.runs {
            XCTAssertEqual(run.state, .running, "\(run.number)")
            XCTAssertLessThan(run.remainingTime, run.phases[0].duration, "\(run.number)")
        }

        viewModel.selectRun(id: first)
        XCTAssertEqual(viewModel.selectedRunID, first)
        viewModel.deleteRun(id: first)
        XCTAssertEqual(viewModel.selectedRunID, second)
    }

    func testTestStripRunUsesTestStripPaperAndSize() throws {
        var session = DarkroomCatalog.defaultSession
        let stripPaper = try XCTUnwrap(DarkroomCatalog.paper(id: "ilford-multigrade-fb-classic"))
        session.testStripPaper = stripPaper
        session.testStripPaperSize = PaperSize(widthCentimeters: 2.5, heightCentimeters: 10)

        let viewModel = TimerViewModel(session: session)
        viewModel.addTestStripRun()

        let run = try XCTUnwrap(viewModel.runs.first)
        XCTAssertTrue(run.isTestStrip)
        XCTAssertEqual(run.session.paper.id, stripPaper.id)
        XCTAssertEqual(run.session.paperSize.widthCentimeters, 2.5)
    }

    /// B13: resetting the project goes back to the catalog defaults and drops the sheets.
    func testResetProjectRestoresDefaultsAndClearsRuns() {
        let viewModel = makeViewModel()
        viewModel.addPaperRun()
        viewModel.startOrPause()

        viewModel.resetProject()

        XCTAssertTrue(viewModel.runs.isEmpty)
        XCTAssertNil(viewModel.selectedRunID)
        XCTAssertEqual(viewModel.session.paper.id, DarkroomCatalog.defaultSession.paper.id)
        XCTAssertTrue(viewModel.isStartPauseDisabled)
    }

    /// B14/B15: changing the setup re-derives the phases of the selected sheet at once.
    func testConfiguringSelectedRunAppliesNewTimesImmediately() throws {
        let viewModel = makeViewModel()
        viewModel.addPaperRun()
        viewModel.startOrPause()

        var session = viewModel.session
        session.phaseDurationOverrides[.developer] = 42

        viewModel.configureSelectedRun(session: session)

        XCTAssertEqual(viewModel.phases.first?.duration, 42)
        XCTAssertEqual(viewModel.remainingTime, 42)
        XCTAssertEqual(viewModel.state, .idle)
    }

    /// 12: a finished sheet can be corrected (wrong size) without paying for the
    /// chemistry twice, and it must not become runnable again.
    func testEditingFinishedRunRevisesUsageInsteadOfCountingItAgain() throws {
        let store = ChemicalUsageStore.shared
        var session = DarkroomCatalog.defaultSession
        let smallSize = try XCTUnwrap(session.paper.availableSizes.first)
        let largeSize = try XCTUnwrap(session.paper.availableSizes.last)
        session.paperSize = smallSize
        store.reset(chemical: session.developer, dilution: session.developerDilution)

        let viewModel = TimerViewModel(session: session)
        viewModel.addPaperRun()
        let start = Date()
        viewModel.startOrPause()
        viewModel.catchUp(to: start.addingTimeInterval(viewModel.phases.reduce(0) { $0 + $1.duration } + 60))
        XCTAssertEqual(viewModel.state, .finished)

        let recorded = store.entries(for: session.developer, dilution: session.developerDilution)
        XCTAssertEqual(recorded.count, 1)
        XCTAssertEqual(recorded.first?.areaSquareMeters, smallSize.areaSquareMeters)

        session.paperSize = largeSize
        viewModel.configureSelectedRun(session: session)

        let revised = store.entries(for: session.developer, dilution: session.developerDilution)
        XCTAssertEqual(revised.count, 1)
        XCTAssertEqual(revised.first?.areaSquareMeters, largeSize.areaSquareMeters)
        XCTAssertEqual(viewModel.state, .finished)
        XCTAssertTrue(viewModel.isStartPauseDisabled)
        XCTAssertEqual(viewModel.session.paperSize.id, largeSize.id)

        store.reset(chemical: session.developer, dilution: session.developerDilution)
    }

    func testFormattedRemainingTimeShowsPlaceholderWithoutRuns() {
        let viewModel = makeViewModel()
        XCTAssertEqual(viewModel.formattedRemainingTime, "--:--")

        viewModel.addPaperRun()
        XCTAssertNotEqual(viewModel.formattedRemainingTime, "--:--")
    }
}
