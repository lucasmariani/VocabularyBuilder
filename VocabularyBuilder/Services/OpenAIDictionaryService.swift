import Foundation
import OpenAIForSwift

class OpenAIDictionaryService: DictionaryServiceProtocol {
    private let openAIService: OpenAIForSwift.OpenAIService
    
    init() {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String, !apiKey.isEmpty else {
            fatalError("OpenAI API key is required")
        }
        
        self.openAIService = OpenAIServiceFactory.service(apiKey: apiKey)
    }
    
    func fetchDefinition(for word: String) async throws -> DictionaryEntry {
        let systemPrompt = """
        You are a comprehensive multilingual dictionary. When given a word, provide a complete dictionary entry.
        
        Guidelines:
        - Provide definitions in the same language as the input word when possible
        - Include multiple meanings/parts of speech if they exist
        - Keep definitions clear and concise
        - Include realistic example sentences
        - Provide relevant synonyms
        - If you don't know the word, return the word with an empty meanings array
        - Always return valid data matching the provided schema
        """
        
        let userPrompt = "Define the word: \(word)"
        
        let systemMessage = OpenAIForSwift.InputMessage(
            role: "system",
            content: .text(systemPrompt),
            type: "message"
        )
        
        let userMessage = OpenAIForSwift.InputMessage(
            role: "user",
            content: .text(userPrompt),
            type: "message"
        )
        
        // Create simplified flat JSON schema
        let vocabularySchema = JsonSchema(
            type: .object,
            description: "Vocabulary word entry",
            properties: [
                "word": JsonSchema(type: .string, description: "The word"),
                "pronunciation": JsonSchema(type: .string, description: "How to pronounce it"),
                "partOfSpeech": JsonSchema(type: .string, description: "noun, verb, adjective, etc."),
                "definition": JsonSchema(type: .string, description: "Primary meaning"),
                "example": JsonSchema(type: .string, description: "Example sentence"),
                "synonyms": JsonSchema(
                    type: .array,
                    description: "Similar words",
                    items: JsonSchema(type: .string)
                )
            ],
            required: ["word", "pronunciation", "partOfSpeech", "definition", "example", "synonyms"]
        )
        
        let request = OpenAIForSwift.ModelResponseParameter(
            input: .array([.message(systemMessage), .message(userMessage)]),
            model: .gpt41nano,
            instructions: "Return a complete vocabulary entry. If no synonyms exist, return an empty array. Always provide an example sentence.",
            maxOutputTokens: 1000,
            temperature: 0.1,
            text: TextConfiguration(format: .jsonSchema(name: "VocabularyEntry", schema: vocabularySchema))
        )
        
        do {
            let response = try await openAIService.responseCreate(request)
            
            guard let content = response.outputText else {
                throw OpenAIDictionaryError.noContent
            }
            
            return try parseDictionaryResponse(content, originalWord: word)
            
        } catch let error as OpenAIForSwift.APIError {
            throw mapOpenAIError(error)
        } catch {
            throw OpenAIDictionaryError.networkError(error)
        }
    }
    
    private func parseDictionaryResponse(_ content: String, originalWord: String) throws -> DictionaryEntry {
        guard let data = content.data(using: .utf8) else {
            throw OpenAIDictionaryError.parsingError
        }
        
        // With structured outputs, we're guaranteed the correct JSON structure
        let vocabularyResponse = try JSONDecoder().decode(SimplifiedVocabularyResponse.self, from: data)
        
        // Convert flat response to nested DictionaryEntry structure
        let definition = DictionaryEntry.Meaning.Definition(
            definition: vocabularyResponse.definition,
            example: vocabularyResponse.example,
            synonyms: vocabularyResponse.synonyms
        )
        
        let meaning = DictionaryEntry.Meaning(
            partOfSpeech: vocabularyResponse.partOfSpeech,
            definitions: [definition]
        )
        
        return DictionaryEntry(
            word: vocabularyResponse.word,
            phonetic: vocabularyResponse.pronunciation,
            meanings: [meaning]
        )
    }
    
    private func mapOpenAIError(_ error: OpenAIForSwift.APIError) -> OpenAIDictionaryError {
        switch error {
        case .requestFailed(let description):
            return .networkError(NSError(
                domain: "OpenAIRequestFailed",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: description]
            ))
        case .responseUnsuccessful(_, let statusCode):
            return .apiError(statusCode: statusCode)
        case .invalidData, .jsonDecodingFailure, .dataCouldNotBeReadMissingData, .bothDecodingStrategiesFailed:
            return .parsingError
        case .timeOutError:
            return .networkError(URLError(.timedOut))
        }
    }
}

// MARK: - Response Models

private struct SimplifiedVocabularyResponse: Codable {
    let word: String
    let pronunciation: String
    let partOfSpeech: String
    let definition: String
    let example: String
    let synonyms: [String]
}


// MARK: - Error Types

enum OpenAIDictionaryError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(statusCode: Int)
    case noContent
    case parsingError
    case networkError(Error)
    case wordNotFound
    case missingAPIKey
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL for OpenAI request"
        case .invalidResponse:
            return "Invalid response from OpenAI"
        case .apiError(let statusCode):
            return "OpenAI API error with status code: \(statusCode)"
        case .noContent:
            return "No content received from OpenAI"
        case .parsingError:
            return "Error parsing OpenAI response"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .wordNotFound:
            return "Word not found in OpenAI dictionary"
        case .missingAPIKey:
            return "OpenAI API key is missing"
        }
    }
}
