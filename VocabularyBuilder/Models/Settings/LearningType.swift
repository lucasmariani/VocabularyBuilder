//
//  Language.swift
//  VocabularyBuilder
//
//  Created by Lucas on 19.07.25.
//

import Foundation

/// Represents different learning approaches for vocabulary building
enum LearningType: String, CaseIterable {
    case newLanguage
    case addingVocabulary
    
    var displayName: String {
        switch self {
        case .newLanguage:
            return NSLocalizedString("learningType.newLanguage", comment: "Learning new language option")
        case .addingVocabulary:
            return NSLocalizedString("learningType.addingVocabulary", comment: "Adding vocabulary option")
        }
    }
    
    var description: String {
        switch self {
        case .newLanguage:
            return NSLocalizedString("learningType.description.newLanguage", comment: "New language description")
        case .addingVocabulary:
            return NSLocalizedString("learningType.description.addingVocabulary", comment: "Adding vocabulary description")
        }
    }
}
