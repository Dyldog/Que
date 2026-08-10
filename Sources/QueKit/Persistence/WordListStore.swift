import Foundation

/// CRUD storage for user-created fixed lists and generation prompts.
public protocol WordListStore: AnyObject {
    func userLists() throws -> [WordList]
    func save(_ list: WordList) throws
    func delete(id: String) throws
}
