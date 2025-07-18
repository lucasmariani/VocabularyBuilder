import Foundation

/// Represents different learning approaches for vocabulary building
enum LearningType: String, CaseIterable {
    case newLanguage
    case addingVocabulary
    
    var displayName: String {
        switch self {
        case .newLanguage:
            return "Learning new language"
        case .addingVocabulary:
            return "Adding Vocabulary to known language"
        }
    }
    
    var description: String {
        switch self {
        case .newLanguage:
            return "Definition will be presented in chosen app language"
        case .addingVocabulary:
            return "Definition will be presented in looked-up word language"
        }
    }
}
