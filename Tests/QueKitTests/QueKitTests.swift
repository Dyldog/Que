import Foundation
import Testing
@testable import QueKit

struct QueKitTests {
    @Test
    func bundledLibraryIncludesPersonalSpanishLists() {
        #expect(QueListLibrary.builtInLists.count == 5)
        #expect(QueListLibrary.personalBundledLists.count == 2)
        #expect(QueListLibrary.personalBundledLists.allSatisfy { !$0.words.isEmpty })
    }

    @Test
    func fileStoreSavesUpdatesAndDeletesLists() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let store = ICloudWordListStore(rootURL: root)
        var list = WordList(
            id: "mine",
            name: "Mine",
            kind: .custom,
            front: .spanish,
            back: .english,
            words: [Word(front: "hola", back: "hello")]
        )

        try store.save(list)
        #expect(try store.userLists() == [list])

        list.name = "Updated"
        try store.save(list)
        #expect(try store.userLists() == [list])

        try store.delete(id: list.id)
        #expect(try store.userLists().isEmpty)
    }

    @Test
    func knownVocabularyRecordsCorrectAnswersAcrossAttempts() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let store = ICloudKnownVocabularyStore(rootURL: root)
        let word = Word(front: "hola", back: "hello")

        try store.recordCorrect(word: word, frontLanguage: .spanish, backLanguage: .english)
        try store.recordCorrect(word: word, frontLanguage: .spanish, backLanguage: .english)

        let record = try #require(store.knownWords().first)
        #expect(record.spanish == "hola")
        #expect(record.english == "hello")
        #expect(record.correctCount == 2)
    }

    @Test
    func legacyUserDefaultsMigrationOnlyRunsOnce() throws {
        let suiteName = UUID().uuidString
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let store = ICloudWordListStore(rootURL: root)
        let list = WordList(name: "Legacy", kind: .prompt, front: .spanish, back: .english, prompt: "travel")
        defaults.set(try JSONEncoder().encode([list]), forKey: UserDefaultsWordListMigrator.legacyKey)

        #expect(try UserDefaultsWordListMigrator.migrateIfNeeded(defaults: defaults, to: store) == 1)
        #expect(try UserDefaultsWordListMigrator.migrateIfNeeded(defaults: defaults, to: store) == 0)
        #expect(try store.userLists() == [list])
    }
}
