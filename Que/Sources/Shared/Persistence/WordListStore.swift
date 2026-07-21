import Foundation

/// Persists the user's own lists — both fixed custom lists and generation prompts.
protocol WordListStore: AnyObject {
    func userLists() -> [WordList]
    func save(_ list: WordList)
    func delete(id: String)
}
