import Foundation
import Observation

struct DictionaryEntry {
    let word: String
    let language: String
    let meanings: [Meaning]

    struct Meaning {
        let partOfSpeech: String
        let definitions: [Definition]

        struct Definition {
            let definition: String
            let example: String?
            let synonyms: [String]
        }
    }
}

@Observable
@MainActor
class DictionaryService {
    private let provider: DictionaryServiceProtocol

    var isLoading = false

    init(provider: DictionaryServiceProtocol) {
        self.provider = provider
    }

    convenience init() {
        // Default to OpenAI provider - API key configured in Info.plist
        let openAIProvider = OpenAIDictionaryService()
        self.init(provider: openAIProvider)
    }

    func fetchDefinition(for word: String, lexicalClass: LexicalClass?, language: Language?, linguisticContext: String?) async throws -> DictionaryEntry {
        isLoading = true

        defer {
            isLoading = false
        }

        return try await provider.fetchDefinition(for: word, lexicalClass: lexicalClass, language: language, linguisticContext: linguisticContext)
    }

    func fetchDefinitionMock(for word: String) async -> DictionaryEntry {
        let mockEntry = DictionaryEntry(
            word: word,
            language: "spanish",
            meanings: [
                DictionaryEntry.Meaning(
                    partOfSpeech: "noun",
                    definitions: [
                        DictionaryEntry.Meaning.Definition(
                            definition: "A sample definition for the word \(word)",
                            example: "This is an example sentence using \(word).",
                            synonyms: ["sample", "example"]
                        )
                    ]
                )
            ]
        )

        return mockEntry
    }

    private func convertAPIResponse(_ response: DictionaryAPIResponse) -> DictionaryEntry {
        let meanings = response.meanings.map { meaning in
            let definitions = meaning.definitions.map { definition in
                DictionaryEntry.Meaning.Definition(
                    definition: definition.definition,
                    example: definition.example,
                    synonyms: definition.synonyms ?? []
                )
            }

            return DictionaryEntry.Meaning(
                partOfSpeech: meaning.partOfSpeech,
                definitions: definitions
            )
        }

        return DictionaryEntry(
            word: response.word,
            language: response.language,
            meanings: meanings
        )
    }
}

private struct DictionaryAPIResponse: Codable {
    let word: String
    let language: String
    let phonetic: String?
    let meanings: [APIResponseMeaning]

    struct APIResponseMeaning: Codable {
        let partOfSpeech: String
        let definitions: [APIResponseDefinition]

        struct APIResponseDefinition: Codable {
            let definition: String
            let example: String?
            let synonyms: [String]?
        }
    }
}

enum DictionaryError: Error, LocalizedError {
    case invalidURL
    case noData
    case wordNotFound
    case parsingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL for dictionary request"
        case .noData:
            return "No data received from dictionary service"
        case .wordNotFound:
            return "Word not found in dictionary"
        case .parsingError:
            return "Error parsing dictionary response"
        }
    }
}
