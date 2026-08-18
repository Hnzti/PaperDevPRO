import Foundation

#if canImport(UserNotifications)
import UserNotifications
#endif

/// Local notifications for runs that finish while the app is in the background.
///
/// Nothing is scheduled while the app is in front (the timer beeps itself) and the
/// notification only covers the *end of the whole process* – no per-phase pings.
@MainActor
final class RunCompletionNotifier {
    static let shared = RunCompletionNotifier()

    struct PendingCompletion {
        let id: UUID
        let title: String
        let date: Date
    }

    private let identifierPrefix = "run.completion."
    private var didRequestAuthorization = false

    private init() {}

    /// Called when the user starts a timer, i.e. the first moment the permission
    /// actually makes sense to ask for.
    func prepareAuthorization() {
        #if canImport(UserNotifications)
        guard !didRequestAuthorization else { return }
        didRequestAuthorization = true

        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { _, _ in }
        #endif
    }

    func schedule(_ completions: [PendingCompletion], body: String, playSound: Bool) {
        #if canImport(UserNotifications)
        let center = UNUserNotificationCenter.current()
        cancelAll()

        for completion in completions {
            let interval = completion.date.timeIntervalSinceNow
            guard interval > 0.5 else { continue }

            let content = UNMutableNotificationContent()
            content.title = completion.title
            content.body = body
            content.sound = playSound ? .default : nil

            let request = UNNotificationRequest(
                identifier: identifierPrefix + completion.id.uuidString,
                content: content,
                trigger: UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            )

            center.add(request)
        }
        #endif
    }

    func cancelAll() {
        #if canImport(UserNotifications)
        let prefix = identifierPrefix

        Task {
            let center = UNUserNotificationCenter.current()
            let identifiers = await center.pendingNotificationRequests()
                .map(\.identifier)
                .filter { $0.hasPrefix(prefix) }

            guard !identifiers.isEmpty else { return }
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
        #endif
    }
}
