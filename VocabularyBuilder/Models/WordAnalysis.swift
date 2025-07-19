//
//  WordAnalysis.swift
//  VocabularyBuilder
//
//  Created by Lucas on 19.07.25.
//

import Foundation

/// Represents the analysis result for a single word
struct WordAnalysis {
    /// The analyzed word
    let word: String
    /// The range of the word in the original text
    let range: NSRange
    /// The lexical class (part of speech) of the word, if determined
    let lexicalClass: LexicalClass?
    /// The detected language of the word (ISO language code like "en", "fr", "es")
    let language: Language?
}
