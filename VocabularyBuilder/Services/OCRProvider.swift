import UIKit
import Foundation

protocol OCRProvider {
    var displayName: String { get }
    var isAvailable: Bool { get }
    func recognizeText(from image: UIImage) async -> OCRResult?
}

enum OCRProviderType: String, CaseIterable {
    case vision = "vision"
    case openAI = "openAI"

    var displayName: String {
        switch self {
        case .vision:
            return "iOS Vision"
        case .openAI:
            return "OpenAI"
        }
    }
}

enum OCRProviderError: Error, LocalizedError {
    case providerNotAvailable
    case apiKeyMissing
    case networkError(Error)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .providerNotAvailable:
            return "OCR provider is not available"
        case .apiKeyMissing:
            return "OpenAI API key is missing"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from OCR service"
        }
    }
}
