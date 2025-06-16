import Foundation

// MARK: - OpenAI Responses API Models for OCR
// Based on correct implementation from openAIClient

// MARK: - Main Request Parameter

public struct ModelResponseParameter: Codable, Sendable {
    
    public init(
        input: InputType,
        model: Model,
        instructions: String? = nil,
        maxOutputTokens: Int? = nil,
        temperature: Double? = nil
    ) {
        self.input = input
        self.model = model.value
        self.instructions = instructions
        self.maxOutputTokens = maxOutputTokens
        self.temperature = temperature
    }
    
    public var input: InputType
    public var model: String
    public var instructions: String?
    public var maxOutputTokens: Int?
    public var temperature: Double?
    
    enum CodingKeys: String, CodingKey {
        case input, model, instructions, temperature
        case maxOutputTokens = "max_output_tokens"
    }
}

// MARK: - OpenAI Models
/// [Models](https://platform.openai.com/docs/models)
public enum Model: Sendable, Codable, Equatable, Hashable, CaseIterable {
    public static let allCases: [Model] = [.gpt4omini, .gpt41nano]

    case gpt4omini
    case gpt41nano

    public init(value: String) {
        switch value {
        case "gpt-4o-mini": self = .gpt4omini
        case "gpt-4.1-nano": self = .gpt41nano
        default: self = .gpt41nano
        }
    }

    public var value: String {
        switch self {
        case .gpt4omini: "gpt-4o-mini"
        case .gpt41nano: "gpt-4.1-nano"
        }
    }

    public var displayName: String {
        switch self {
        case .gpt4omini: "GPT-4o mini"
        case .gpt41nano: "GPT-4.1 nano"
        }
    }
}

// MARK: - Role

public enum Role: Codable, Sendable {
    case developer, user, assistant, system
}

// MARK: - Input Type

public enum InputType: Codable, Sendable {
    case string(String)
    case array([InputItem])
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let text = try? container.decode(String.self) {
            self = .string(text)
        } else if let array = try? container.decode([InputItem].self) {
            self = .array(array)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Input must be a string or an array of input items")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let text):
            try container.encode(text)
        case .array(let items):
            try container.encode(items)
        }
    }
}

// MARK: - Input Item

public enum InputItem: Codable, Sendable {
    case message(InputMessage)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "message":
            self = try .message(InputMessage(from: decoder))
        default:
            self = try .message(InputMessage(from: decoder))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .message(let message):
            try message.encode(to: encoder)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
    }
}

// MARK: - Input Message

public struct InputMessage: Codable, Sendable {
    public init(role: Role, content: MessageContent, type: String? = "message") {
        self.role = role
        self.content = content
        self.type = type
    }
    
    public let role: Role
    public let content: MessageContent
    public let type: String?
}

// MARK: - Message Content

public enum MessageContent: Codable, Sendable {
    case text(String)
    case array([ContentItem])
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let text = try? container.decode(String.self) {
            self = .text(text)
        } else if let array = try? container.decode([ContentItem].self) {
            self = .array(array)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Content must be a string or an array of content items")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .text(let text):
            try container.encode(text)
        case .array(let items):
            try container.encode(items)
        }
    }
}

// MARK: - Content Item

public enum ContentItem: Codable, Sendable {
    case text(TextContent)
    case image(ImageContent)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        let singleValueContainer = try decoder.singleValueContainer()
        
        switch type {
        case "input_text":
            self = try .text(singleValueContainer.decode(TextContent.self))
        case "input_image":
            self = try .image(singleValueContainer.decode(ImageContent.self))
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown content type: \(type)")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .text(let text):
            try container.encode(text)
        case .image(let image):
            try container.encode(image)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
    }
}

// MARK: - Text Content

public struct TextContent: Codable, Sendable {
    public let text: String
    public let type = "input_text"
    
    public init(text: String) {
        self.text = text
    }
    
    enum CodingKeys: String, CodingKey {
        case text, type
    }
}

// MARK: - Image Content

public struct ImageContent: Codable, Sendable {
    public init(detail: String = "auto", fileId: String? = nil, imageUrl: String? = nil) {
        self.detail = detail
        self.fileId = fileId
        self.imageUrl = imageUrl
    }
    
    public let type = "input_image"
    public let detail: String
    public let fileId: String?
    public let imageUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case type, detail
        case fileId = "file_id"
        case imageUrl = "image_url"
    }
}

// MARK: - Response Models

public struct ResponseModel: Decodable, Sendable {
    public let id: String
    public let object: String
    public let createdAt: Int
    public let model: String
    public let output: [OutputItem]
    public let usage: Usage?
    
    public var outputText: String? {
        let outputTextItems = output.compactMap { outputItem -> String? in
            switch outputItem {
            case .message(let message):
                return message.content.compactMap { contentItem -> String? in
                    switch contentItem {
                    case .outputText(let outputText):
                        return outputText.text
                    }
                }.joined()
            }
        }
        return outputTextItems.isEmpty ? nil : outputTextItems.joined()
    }
    
    enum CodingKeys: String, CodingKey {
        case id, object, model, output, usage
        case createdAt = "created_at"
    }
}

public enum OutputItem: Decodable, Sendable {
    case message(Message)

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "message":
            let message = try Message(from: decoder)
            self = .message(message)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type,
                in: container,
                debugDescription: "Unknown output item type: \(type)")
        }
    }

    public struct Message: Decodable, Sendable {
        public let content: [ContentItem]
        public let id: String
        public let role: Role
        public let type: String

        enum CodingKeys: String, CodingKey {
            case content, id, role, type
        }
    }

    public enum ContentItem: Decodable, Sendable {
        case outputText(OutputText)

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)

            switch type {
            case "output_text":
                let text = try OutputText(from: decoder)
                self = .outputText(text)
            default:
                throw DecodingError.dataCorruptedError(
                    forKey: .type,
                    in: container,
                    debugDescription: "Unknown content item type: \(type)")
            }
        }

        public struct OutputText: Decodable, Sendable {
            public let text: String
            public let type: String

            enum CodingKeys: String, CodingKey {
                case text, type
            }
        }

        private enum CodingKeys: String, CodingKey {
            case type
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type
    }
}

public struct Usage: Codable, Sendable {
    public let promptTokens: Int?
    public let completionTokens: Int?
    public let totalTokens: Int?

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

// MARK: - Error Models

public struct OpenAIError: Codable, Error {
    let error: OpenAIErrorDetail
}

public struct OpenAIErrorDetail: Codable, Sendable {
    let message: String
    let type: String
    let code: String?
}
