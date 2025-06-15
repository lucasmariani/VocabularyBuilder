import Foundation
import Combine

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

@MainActor
class DictionaryService: ObservableObject {
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()

    @Published var isLoading = false

    nonisolated func fetchDefinition(for word: String) -> AnyPublisher<DictionaryEntry, Error> {
        return Future<DictionaryEntry, Error> { [weak self] promise in
            Task { @MainActor [weak self] in
                self?.isLoading = true
            }

            guard let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en/\(word.lowercased())") else {
                Task { @MainActor [weak self] in
                    self?.isLoading = false
                }
                promise(.failure(DictionaryError.invalidURL))
                return
            }

            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                defer {
                    Task { @MainActor [weak self] in
                        self?.isLoading = false
                    }
                }

                if let error = error {
                    promise(.failure(error))
                    return
                }

                guard let data = data else {
                    promise(.failure(DictionaryError.noData))
                    return
                }

                do {
                    let apiResponse = try JSONDecoder().decode([DictionaryAPIResponse].self, from: data)

                    guard let firstEntry = apiResponse.first else {
                        promise(.failure(DictionaryError.wordNotFound))
                        return
                    }

                    let dictionaryEntry = self?.convertAPIResponse(firstEntry) ?? DictionaryEntry(word: word, phonetic: nil, meanings: [])
                    promise(.success(dictionaryEntry))

                } catch {
                    promise(.failure(DictionaryError.parsingError))
                }
            }.resume()
        }
        .eraseToAnyPublisher()
    }

    func fetchDefinitionMock(for word: String) -> AnyPublisher<DictionaryEntry, Error> {
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

        return Just(mockEntry)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    nonisolated private func convertAPIResponse(_ response: DictionaryAPIResponse) -> DictionaryEntry {
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
