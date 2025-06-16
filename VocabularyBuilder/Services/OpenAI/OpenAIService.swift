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
        
        let request = OpenAIRequest(
            model: "gpt-4o-mini",
            messages: [
                OpenAIMessage(
                    role: "user",
                    content: [
                        OpenAIContent(
                            type: "text",
                            text: "Extract all text from this image. Return only the text content, preserving line breaks and formatting. Do not include any additional commentary or explanation.",
                            imageUrl: nil
                        ),
                        OpenAIContent(
                            type: "image_url",
                            text: nil,
                            imageUrl: OpenAIImageURL(url: dataURL)
                        )
                    ]
                )
            ],
            maxTokens: 1000,
            temperature: 0.1
        )
        
        var urlRequest = URLRequest(url: URL(string: "\(baseURL)/chat/completions")!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
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
            
            let openAIResponse = try decoder.decode(OpenAIResponse.self, from: data)
            
            guard let firstChoice = openAIResponse.choices.first else {
                throw OCRProviderError.invalidResponse
            }
            
            return firstChoice.message.content.trimmingCharacters(in: .whitespacesAndNewlines)
            
        } catch let error as DecodingError {
            print("OpenAI Decoding error: \(error)")
            throw OCRProviderError.invalidResponse
        } catch {
            print("OpenAI Network error: \(error)")
            throw OCRProviderError.networkError(error)
        }
    }
}
