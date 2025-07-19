import Foundation

protocol DictionaryServiceProtocol {
    func fetchDefinition(for word: String, lexicalClass: LexicalClass?, language: Language?, linguisticContext: String?) async throws -> DictionaryEntry
}
