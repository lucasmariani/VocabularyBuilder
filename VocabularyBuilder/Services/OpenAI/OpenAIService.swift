import Foundation
import UIKit

class OpenAIService {
    private let baseURL = "https://api.openai.com/v1"
    private let session: URLSession
    private let decoder: JSONDecoder
    
    private var apiKey: String? {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
            fatalError("Error retrieving API_KEY")
        }
        return apiKey
    }
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
    }
    
    func extractTextFromImage(_ image: UIImage) async throws -> String {
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            throw OCRProviderError.apiKeyMissing
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw OCRProviderError.invalidResponse
        }
        
        let base64Image = imageData.base64EncodedString()
        let dataURL = "data:image/jpeg;base64,\(base64Image)"
        
        // Build the correct request structure with proper nesting
        let contentItems: [ContentItem] = [
            .text(TextContent(text: "Extract all text from this image. Return only the text content, preserving line breaks and formatting. Do not include any additional commentary or explanation.")),
            .image(ImageContent(
                detail: "auto",
                fileId: nil,
                imageUrl: dataURL
            ))
        ]
        
        let inputMessage = InputMessage(
            role: .user,
            content: .array(contentItems),
            type: "message"
        )
        
        let request = ModelResponseParameter(
            input: .array([.message(inputMessage)]),
            model: .gpt41nano,
            instructions: "You are an OCR assistant. Extract text from images accurately.",
            maxOutputTokens: 1000,
            temperature: 0.1
        )

        guard let url = URL(string: "\(baseURL)/responses") else {
            throw OCRProviderError.invalidResponse
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            print("OpenAI Encoding error: \(error)")
            throw OCRProviderError.invalidResponse
        }
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw OCRProviderError.networkError(URLError(.badServerResponse))
            }
            
            if httpResponse.statusCode != 200 {
                // Try to decode error response
                if let errorResponse = try? decoder.decode(OpenAIError.self, from: data) {
                    throw OCRProviderError.networkError(NSError(
                        domain: "OpenAIError",
                        code: httpResponse.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: errorResponse.error.message]
                    ))
                } else {
                    throw OCRProviderError.networkError(URLError(.badServerResponse))
                }
            }
            
            let openAIResponse = try decoder.decode(ResponseModel.self, from: data)
            
            // Use the convenience property to extract text
            guard let extractedText = openAIResponse.outputText else {
                throw OCRProviderError.invalidResponse
            }
            
            return extractedText.trimmingCharacters(in: .whitespacesAndNewlines)
            
        } catch let error as DecodingError {
            print("OpenAI Decoding error: \(error)")
            throw OCRProviderError.invalidResponse
        } catch {
            print("OpenAI Network error: \(error)")
            throw OCRProviderError.networkError(error)
        }
    }
}
