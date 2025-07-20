//
//  LanguageConverter.swift
//  VocabularyBuilder
//
//  Created by Lucas on 19.07.25.
//

import NaturalLanguage

// Utility struct for language conversion
struct LanguageConverter {
    /// Converts a language code to its English name
    /// - Parameter code: The language code (ISO 639-1 or NLLanguage format)
    /// - Returns: The English name of the language, or nil if the code is not recognized
    static func languageName(for code: String) -> String? {
        Language(rawValue: code)?.englishName
    }
    
    /// Converts a language code to its English name with a fallback
    /// - Parameters:
    ///   - code: The language code
    ///   - fallback: The string to return if the language code is not recognized
    /// - Returns: The English name of the language, or the fallback string
    static func languageName(for code: String, fallback: String = NSLocalizedString("language.unknown", comment: "Unknown language")) -> String {
        languageName(for: code) ?? fallback
    }
    
    /// Converts an NLLanguage to its English name
    /// - Parameter language: The NLLanguage instance
    /// - Returns: The English name of the language
    static func languageName(for language: NLLanguage) -> String {
        languageName(for: language.rawValue, fallback: NSLocalizedString("language.unknown", comment: "Unknown language"))
    }
}

extension String {
    /// Converts a language code to its English name
    /// - Returns: The English name of the language, or nil if the code is not recognized
    func toLanguageName() -> String? {
        Language(rawValue: self)?.englishName
    }
}
