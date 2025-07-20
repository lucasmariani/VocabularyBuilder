//
//  TextFormattingConfiguration.swift
//  VocabularyBuilder
//
//  Created by Lucas on 19.07.25.
//

import UIKit

/// Configuration for text formatting
struct TextFormattingConfiguration {
    /// Base font for regular text
    let baseFont: UIFont
    /// Base text color
    let baseTextColor: UIColor
    /// Set of lexical classes that should be highlighted
    let highlightedLexicalClasses: Set<LexicalClass>
    /// Style to apply to highlighted words
    let highlightStyle: TextHighlightStyle
    
    /// Default configuration for vocabulary learning
    static let vocabularyLearning = TextFormattingConfiguration(
        baseFont: UIFont.systemFont(ofSize: 16),
        baseTextColor: UIColor.secondaryLabel,
        highlightedLexicalClasses: [.noun, .adjective, .verb, .adverb],
        highlightStyle: .boldAndColor(.label)
    )
}
