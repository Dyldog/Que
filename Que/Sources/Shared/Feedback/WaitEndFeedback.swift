import AudioToolbox

/// Plays a short system beep to signal that a forced wait has ended.
/// The accompanying vibration is driven by SwiftUI's `.sensoryFeedback` in the view.
enum WaitEndFeedback {
    /// "Tink" — a brief, distinct beep.
    private static let beepSoundID: SystemSoundID = 1057

    static func play() {
        AudioServicesPlaySystemSound(beepSoundID)
    }
}
