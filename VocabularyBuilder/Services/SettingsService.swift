import Foundation
import Observation

/// Centralized service for managing all app settings
@MainActor
@Observable
class SettingsService {
    static let shared = SettingsService()
    
    private struct UserDefaultsKeys {
        static let learningType = "learning_type"
        static let ocrProviderType = "ocr_provider_type"
    }
    
    // MARK: - Learning Type Settings
    
    private(set) var selectedLearningType: LearningType = .newLanguage {
        didSet {
            UserDefaults.standard.set(selectedLearningType.rawValue, forKey: UserDefaultsKeys.learningType)
        }
    }
    
    // MARK: - OCR Provider Settings
    
    private(set) var selectedOCRProviderType: OCRProviderType = .vision {
        didSet {
            UserDefaults.standard.set(selectedOCRProviderType.rawValue, forKey: UserDefaultsKeys.ocrProviderType)
        }
    }
    
    private init() {
        loadSettings()
    }
    
    private func loadSettings() {
        // Load Learning Type
        if let learningTypeString = UserDefaults.standard.string(forKey: UserDefaultsKeys.learningType),
           let learningType = LearningType(rawValue: learningTypeString) {
            self.selectedLearningType = learningType
        }
        
        // Load OCR Provider Type
        if let providerTypeString = UserDefaults.standard.string(forKey: UserDefaultsKeys.ocrProviderType),
           let providerType = OCRProviderType(rawValue: providerTypeString) {
            self.selectedOCRProviderType = providerType
        }
    }
    
    // MARK: - Public Methods
    
    func selectLearningType(_ type: LearningType) {
        selectedLearningType = type
    }
    
    func selectOCRProviderType(_ type: OCRProviderType) {
        selectedOCRProviderType = type
    }
}

// MARK: - SettingsItem Conformance

extension LearningType: SettingsItem {
    var isSelected: Bool {
        return self == SettingsService.shared.selectedLearningType
    }
}

extension OCRProviderType: SettingsItem {
    var description: String {
        switch self {
        case .vision:
            return "Apple's built-in text recognition"
        case .openAI:
            return "AI-powered text extraction via OpenAI"
        }
    }
    
    var isSelected: Bool {
        return self == SettingsService.shared.selectedOCRProviderType
    }
}