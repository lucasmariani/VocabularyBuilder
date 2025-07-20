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
    
    private var providers: [OCRProviderType: OCRProviding] = [:]
    
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
    
    var currentProvider: OCRProviding? {
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
}
