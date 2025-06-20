import Foundation

protocol DictionaryServiceProtocol {
    func fetchDefinition(for word: String) async throws -> DictionaryEntry
}