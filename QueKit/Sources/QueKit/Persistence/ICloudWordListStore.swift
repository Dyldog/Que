import Foundation

/// Stores each user list as its own JSON document in QueKit's shared iCloud Drive container.
public final class ICloudWordListStore: WordListStore {
    private let containerIdentifier: String?
    private let explicitRootURL: URL?
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(
        containerIdentifier: String = QueKitConfiguration.iCloudContainerIdentifier,
        fileManager: FileManager = .default
    ) {
        self.containerIdentifier = containerIdentifier
        explicitRootURL = nil
        self.fileManager = fileManager
        encoder = JSONEncoder()
        decoder = JSONDecoder()
    }

    /// Creates a store rooted at a local URL. Intended for tests and previews.
    public init(rootURL: URL, fileManager: FileManager = .default) {
        containerIdentifier = nil
        explicitRootURL = rootURL
        self.fileManager = fileManager
        encoder = JSONEncoder()
        decoder = JSONDecoder()
    }

    public func userLists() throws -> [WordList] {
        let directory = try listsDirectory(createIfNeeded: true)
        let urls = try fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: [.isUbiquitousItemKey, .ubiquitousItemDownloadingStatusKey],
            options: [.skipsHiddenFiles]
        )

        return urls
            .filter { $0.pathExtension == "json" }
            .compactMap { safelyLoadList(from: $0) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    public func save(_ list: WordList) throws {
        let directory = try listsDirectory(createIfNeeded: true)
        let existingURL = try listDocuments(in: directory)
            .first { safelyLoadList(from: $0)?.id == list.id }
        let destination = existingURL ?? directory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        try encoder.encode(list).write(to: destination, options: .atomic)
    }

    public func delete(id: String) throws {
        let directory = try listsDirectory(createIfNeeded: true)
        for url in try listDocuments(in: directory) where safelyLoadList(from: url)?.id == id {
            try fileManager.removeItem(at: url)
        }
    }

    private func listsDirectory(createIfNeeded: Bool) throws -> URL {
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
            .appendingPathComponent("Lists", isDirectory: true)
        if createIfNeeded {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }

    private func listDocuments(in directory: URL) throws -> [URL] {
        try fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ).filter { $0.pathExtension == "json" }
    }

    private func loadList(from url: URL) throws -> WordList? {
        let values = try? url.resourceValues(forKeys: [.isUbiquitousItemKey])
        if values?.isUbiquitousItem == true {
            try? fileManager.startDownloadingUbiquitousItem(at: url)
        }
        return try decoder.decode(WordList.self, from: Data(contentsOf: url))
    }

    private func safelyLoadList(from url: URL) -> WordList? {
        try? loadList(from: url)
    }
}
