import UIKit
import Observation
import Vision

@Observable
@MainActor
class OCRServiceManager {
    var isProcessing = false
    var recognizedText = ""
    var ocrResult: OCRResult?
    var selectedProviderType: OCRProviderType = .vision {
        didSet {
            UserDefaults.standard.set(selectedProviderType.rawValue, forKey: "selectedOCRProvider")
        }
    }

    private var providers: [OCRProviderType: OCRProvider] = [:]

    init() {
        setupProviders()
        loadSelectedProvider()
    }

    private func setupProviders() {
        providers[.vision] = VisionOCRProvider()
        providers[.openAI] = OpenAIOCRProvider()
    }

    private func loadSelectedProvider() {
        if let savedProvider = UserDefaults.standard.string(forKey: "selectedOCRProvider"),
           let providerType = OCRProviderType(rawValue: savedProvider) {
            selectedProviderType = providerType
        }
    }

    var currentProvider: OCRProvider? {
        return providers[selectedProviderType]
    }

    var availableProviders: [OCRProviderType] {
        return OCRProviderType.allCases.filter { providers[$0]?.isAvailable == true }
    }

    func recognizeText(from image: UIImage) async -> OCRResult? {
        guard let provider = currentProvider else {
            print("OCRServiceManager: No provider available")
            return nil
        }

        isProcessing = true

        let result = await provider.recognizeText(from: image)

        if let result = result {
            recognizedText = result.recognizedText
            ocrResult = result
        }

        isProcessing = false
        return result
    }

    nonisolated func extractWordsWithBounds(from result: OCRResult) -> [(word: String, bounds: CGRect)] {
        var wordsWithBounds: [(word: String, bounds: CGRect)] = []

        if result.textObservations.isEmpty {
            // For providers like OpenAI that don't provide detailed observations,
            // split the text into words and use the overall bounding box
            let words = result.recognizedText.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
            for word in words {
                wordsWithBounds.append((word: word, bounds: result.boundingBox))
            }
        } else {
            // Use detailed observations when available (like from Vision)
            for observation in result.textObservations {
                guard let candidate = observation.topCandidates(1).first else { continue }

                let words = candidate.string.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }

                for word in words {
                    wordsWithBounds.append((word: word, bounds: observation.boundingBox))
                }
            }
        }

        return wordsWithBounds
    }
}
