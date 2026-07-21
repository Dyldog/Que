import Foundation
@testable import Que

/// A controllable `SpeechRecognizing` for tests: never touches the microphone,
/// and lets a test feed transcripts in directly.
@MainActor
final class FakeSpeechRecognizer: SpeechRecognizing {
    var authorized: Bool
    var isAvailable: Bool
    private(set) var isListening = false
    private var onTranscript: (@MainActor (String) -> Void)?

    nonisolated init(authorized: Bool = true, isAvailable: Bool = true) {
        self.authorized = authorized
        self.isAvailable = isAvailable
    }

    func requestAuthorization() async -> Bool { authorized }

    func start(locale: Locale, onTranscript: @escaping @MainActor (String) -> Void) throws {
        isListening = true
        self.onTranscript = onTranscript
    }

    func stop() {
        isListening = false
        onTranscript = nil
    }

    /// Simulate the recognizer hearing something.
    func hear(_ text: String) {
        onTranscript?(text)
    }
}
