import Foundation
import Observation

struct DictionaryEntry {
    let word: String
    let phonetic: String?
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
    private let session = URLSession.shared

    var isLoading = false

    func fetchDefinition(for word: String) async throws -> DictionaryEntry {
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        guard let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en/\(word.lowercased())") else {
            throw DictionaryError.invalidURL
        }
        
        do {
            let (data, _) = try await session.data(from: url)
            
            let apiResponse = try JSONDecoder().decode([DictionaryAPIResponse].self, from: data)
            
            guard let firstEntry = apiResponse.first else {
                throw DictionaryError.wordNotFound
            }
            
            return convertAPIResponse(firstEntry)
            
        } catch is DecodingError {
            throw DictionaryError.parsingError
        } catch {
            throw error
        }
    }

    func fetchDefinitionMock(for word: String) async -> DictionaryEntry {
        let mockEntry = DictionaryEntry(
            word: word,
            phonetic: "/\(word)/",
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
            phonetic: response.phonetic,
            meanings: meanings
        )
    }
}

private struct DictionaryAPIResponse: Codable {
    let word: String
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
