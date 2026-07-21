import AVFoundation
import Speech

enum SpeechRecognizerError: Error {
    case unavailable
}

/// A `SpeechRecognizing` backed by `SFSpeechRecognizer` and `AVAudioEngine`.
@MainActor
final class SpeechRecognizer: SpeechRecognizing {
    private let audioEngine = AVAudioEngine()
    private var recognizer: SFSpeechRecognizer?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    nonisolated init() {}

    var isAvailable: Bool {
        SFSpeechRecognizer.authorizationStatus() == .authorized
    }

    func requestAuthorization() async -> Bool {
        let speechGranted = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
        guard speechGranted else { return false }

        return await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    func start(locale: Locale, onTranscript: @escaping @MainActor (String) -> Void) throws {
        stop()

        guard let recognizer = SFSpeechRecognizer(locale: locale), recognizer.isAvailable else {
            throw SpeechRecognizerError.unavailable
        }
        self.recognizer = recognizer

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        self.request = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        task = recognizer.recognitionTask(with: request) { result, _ in
            guard let result else { return }
            let text = result.bestTranscription.formattedString
            Task { @MainActor in onTranscript(text) }
        }
    }

    func stop() {
        task?.cancel()
        task = nil

        request?.endAudio()
        request = nil

        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
