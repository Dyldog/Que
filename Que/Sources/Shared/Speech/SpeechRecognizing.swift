import Foundation

/// Listens to the microphone and reports what it hears, so the app can grade a
/// spoken answer without the user tapping anything.
@MainActor
protocol SpeechRecognizing: AnyObject {
    /// Whether speech recognition is authorized and ready to use.
    var isAvailable: Bool { get }

    /// Requests microphone and speech-recognition permission. Returns whether both
    /// were granted.
    func requestAuthorization() async -> Bool

    /// Begins listening in the given locale, reporting each partial transcript.
    func start(locale: Locale, onTranscript: @escaping @MainActor (String) -> Void) throws

    /// Stops listening and releases the microphone.
    func stop()
}
