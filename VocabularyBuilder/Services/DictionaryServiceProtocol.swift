import Foundation

protocol DictionaryServiceProtocol {
    func fetchDefinition(for word: String, linguisticContext: String?) async throws -> DictionaryEntry
}
