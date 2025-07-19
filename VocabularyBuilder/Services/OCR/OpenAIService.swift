import Foundation
import UIKit
import OpenAIForSwift

class OpenAIService {
    private let openAIService: OpenAIForSwift.OpenAIService
    
    private var apiKey: String? {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
            fatalError("Error retrieving API_KEY")
        }
        return apiKey
    }

    public var isAvailable: Bool {
        guard let apiKey = self.apiKey else {
            return false
        }
        return !apiKey.isEmpty
    }

    init() {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String, !apiKey.isEmpty else {
            fatalError("OpenAI API key is required")
        }
        
        self.openAIService = OpenAIServiceFactory.service(apiKey: apiKey)
    }
    
    func extractTextFromImage(_ image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw OCRProviderError.invalidResponse
        }
        
        let base64Image = imageData.base64EncodedString()
        let dataURL = "data:image/jpeg;base64,\(base64Image)"
        
        // Build the correct request structure using package models
        let contentItems: [OpenAIForSwift.ContentItem] = [
            .text(OpenAIForSwift.TextContent(text: "Extract all text from this image. Return only the text content, preserving formatting. If words are hyphenated for line breaks, remove the hyphen and reconstruct the word. Do not include any additional commentary or explanation.")),
            .image(OpenAIForSwift.ImageContent(
                detail: "auto",
                fileId: nil,
                imageUrl: dataURL
            ))
        ]
        
        let inputMessage = OpenAIForSwift.InputMessage(
            role: "user", // Convert from enum to string
            content: .array(contentItems),
            type: "message"
        )
        
        let request = OpenAIForSwift.ModelResponseParameter(
            input: .array([.message(inputMessage)]),
            model: .gpt41nano,
            instructions: "You are an OCR assistant. Extract text from images accurately.",
            maxOutputTokens: 1000,
            temperature: 0.1
        )

        do {
            let response = try await openAIService.responseCreate(request)
            
            // Use the convenience property to extract text
            guard let extractedText = response.outputText else {
                throw OCRProviderError.invalidResponse
            }
            
            return extractedText.trimmingCharacters(in: .whitespacesAndNewlines)
            
        } catch let error as OpenAIForSwift.APIError {
            // Handle OpenAIForSwift package errors
            switch error {
            case .requestFailed(description: let desc, underlyingError: let error):
                throw OCRProviderError.networkError(NSError(
                    domain: "OpenAIRequestFailed",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey: desc]
                ))
            case .responseUnsuccessful(description: let descr, statusCode: let statusCode, httpHeaders: let headers, underlyingError: let error):
                throw OCRProviderError.networkError(NSError(
                    domain: "OpenAIError",
                    code: statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "HTTP \(statusCode): \(statusCode)"]
                ))
            case .invalidData, .jsonDecodingFailure, .dataCouldNotBeReadMissingData, .bothDecodingStrategiesFailed:
                throw OCRProviderError.invalidResponse
            case .timeOutError:
                throw OCRProviderError.networkError(URLError(.timedOut))
            case .streamProcessingError(description: let description, underlyingError: let underlyingError):
                throw OCRProviderError.networkError(underlyingError!) // TODO: fix this.
            }
        } catch {
            throw OCRProviderError.networkError(error)
        }
    }
}
