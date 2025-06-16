import Foundation

// MARK: - OpenAI API Models for OCR

public struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let maxTokens: Int
    let temperature: Double
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

public struct OpenAIMessage: Codable {
    let role: String
    let content: [OpenAIContent]
}

public struct OpenAIContent: Codable {
    let type: String
    let text: String?
    let imageUrl: OpenAIImageURL?
    
    enum CodingKeys: String, CodingKey {
        case type, text
        case imageUrl = "image_url"
    }
}

public struct OpenAIImageURL: Codable {
    let url: String
}

public struct OpenAIResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [OpenAIChoice]
    let usage: OpenAIUsage
}

public struct OpenAIChoice: Codable {
    let index: Int
    let message: OpenAIResponseMessage
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case index, message
        case finishReason = "finish_reason"
    }
}

public struct OpenAIResponseMessage: Codable {
    let role: String
    let content: String
}

public struct OpenAIUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

public struct OpenAIError: Codable, Error {
    let error: OpenAIErrorDetail
}

public struct OpenAIErrorDetail: Codable, Sendable {
    let message: String
    let type: String
    let code: String?
}