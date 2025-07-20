import UIKit
import Foundation

protocol OCRProviding {
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
            return NSLocalizedString("ocrProvider.vision", comment: "iOS Vision OCR provider")
        case .openAI:
            return NSLocalizedString("ocrProvider.openai", comment: "OpenAI OCR provider")
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
            return NSLocalizedString("error.ocr.notAvailable", comment: "OCR provider not available")
        case .apiKeyMissing:
            return NSLocalizedString("error.ocr.missingApiKey", comment: "Missing API key error")
        case .networkError(let error):
            return String(format: NSLocalizedString("error.ocr.networkError", comment: "Network error"), error.localizedDescription)
        case .invalidResponse:
            return NSLocalizedString("error.ocr.invalidResponse", comment: "Invalid response error")
        }
    }
}
