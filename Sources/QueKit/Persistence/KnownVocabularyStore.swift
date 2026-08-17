import Foundation

public protocol KnownVocabularyStore {
    func knownWords() throws -> [KnownWordRecord]
    func recordCorrect(word: Word, frontLanguage: Language, backLanguage: Language) throws
}

/// Shares correctly answered vocabulary between QueKit apps through iCloud Drive.
public final class ICloudKnownVocabularyStore: KnownVocabularyStore {
    private let containerIdentifier: String?
    private let explicitRootURL: URL?
    private let fileManager: FileManager
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(
        containerIdentifier: String = QueKitConfiguration.iCloudContainerIdentifier,
        fileManager: FileManager = .default
    ) {
        self.containerIdentifier = containerIdentifier
        explicitRootURL = nil
        self.fileManager = fileManager
    }

    /// Creates a local store for tests and previews.
    public init(rootURL: URL, fileManager: FileManager = .default) {
        containerIdentifier = nil
        explicitRootURL = rootURL
        self.fileManager = fileManager
    }

    public func knownWords() throws -> [KnownWordRecord] {
        let url = try fileURL(createDirectory: true)
        guard fileManager.fileExists(atPath: url.path) else { return [] }
        let values = try? url.resourceValues(forKeys: [.isUbiquitousItemKey])
        if values?.isUbiquitousItem == true {
            try? fileManager.startDownloadingUbiquitousItem(at: url)
        }
        return try decoder.decode([KnownWordRecord].self, from: Data(contentsOf: url))
    }

    public func recordCorrect(word: Word, frontLanguage: Language, backLanguage: Language) throws {
        var records = try knownWords()
        let newRecord = KnownWordRecord(
            front: word.front,
            back: word.back,
            frontLocaleIdentifier: frontLanguage.localeIdentifier,
            backLocaleIdentifier: backLanguage.localeIdentifier
        )
        if let index = records.firstIndex(where: { $0.identityKey == newRecord.identityKey }) {
            records[index].correctCount += 1
            records[index].lastCorrectAt = Date()
        } else {
            records.append(newRecord)
        }
        let url = try fileURL(createDirectory: true)
        try encoder.encode(records).write(to: url, options: .atomic)
    }

    private func fileURL(createDirectory: Bool) throws -> URL {
        let root: URL
        if let explicitRootURL {
            root = explicitRootURL
        } else if let containerIdentifier,
                  let container = fileManager.url(forUbiquityContainerIdentifier: containerIdentifier) {
            root = container.appendingPathComponent("Documents", isDirectory: true)
        } else {
            throw QueKitStorageError.iCloudContainerUnavailable(
                identifier: containerIdentifier ?? QueKitConfiguration.iCloudContainerIdentifier
            )
        }
        let directory = root
            .appendingPathComponent("QueKit", isDirectory: true)
            .appendingPathComponent("Knowledge", isDirectory: true)
        if createDirectory {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory.appendingPathComponent("known-words.json")
    }
}
