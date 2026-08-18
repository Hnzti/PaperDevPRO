import Foundation

#if canImport(AVFoundation)
import AVFoundation
#endif

#if canImport(UIKit)
import UIKit
#endif

/// Timer cues: a beep that ducks music, still obeys the Ring/Silent switch,
/// and a pre-warmed haptic so the first tick is not late.
@MainActor
final class DarkroomFeedback {
    static let shared = DarkroomFeedback()

    enum Cue {
        case warning
        case phaseChange
        case completion

        var resource: String {
            switch self {
            case .warning: return "darkroom-warning"
            case .phaseChange: return "darkroom-phase"
            case .completion: return "darkroom-complete"
            }
        }
    }

    #if canImport(UIKit)
    private let warningHaptics = UINotificationFeedbackGenerator()
    private let successHaptics = UINotificationFeedbackGenerator()
    #endif

    #if canImport(AVFoundation)
    private var player: AVAudioPlayer?
    #endif

    private var didConfigureSession = false

    private init() {}

    func prepare() {
        #if canImport(UIKit)
        warningHaptics.prepare()
        successHaptics.prepare()
        #endif
        configureSessionIfNeeded()
    }

    func play(_ cue: Cue, sound: Bool, haptics: Bool) {
        if sound {
            playSound(cue)
        }

        #if canImport(UIKit)
        if haptics {
            switch cue {
            case .warning:
                warningHaptics.notificationOccurred(.warning)
                warningHaptics.prepare()
            case .phaseChange, .completion:
                successHaptics.notificationOccurred(.success)
                successHaptics.prepare()
            }
        }
        #endif
    }

    private func configureSessionIfNeeded() {
        #if canImport(AVFoundation)
        guard !didConfigureSession else { return }
        didConfigureSession = true

        let session = AVAudioSession.sharedInstance()
        // `.soloAmbient` stops other audio (music) but still respects Silent.
        try? session.setCategory(.soloAmbient, mode: .default)
        try? session.setActive(true)
        #endif
    }

    private func playSound(_ cue: Cue) {
        #if canImport(AVFoundation)
        configureSessionIfNeeded()

        guard let url = Bundle.main.url(forResource: cue.resource, withExtension: "wav") else {
            return
        }

        player = try? AVAudioPlayer(contentsOf: url)
        player?.prepareToPlay()
        player?.play()
        #endif
    }
}
