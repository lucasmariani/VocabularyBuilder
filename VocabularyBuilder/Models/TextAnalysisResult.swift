//
//  TextAnalysisResult.swift
//  VocabularyBuilder
//
//  Created by Lucas on 19.07.25.
//

import Foundation

/// Represents the complete analysis result for a text
struct TextAnalysisResult {
    /// The original text that was analyzed
    let originalText: String
    /// Array of word analyses in order of appearance
    let wordAnalyses: [WordAnalysis]

    /// Returns all words that match the specified lexical classes
    func words(withLexicalClasses lexicalClasses: Set<String>) -> [WordAnalysis] {
        return wordAnalyses.filter { analysis in
            guard let lexicalClass = analysis.lexicalClass else { return false }
            return lexicalClasses.contains(lexicalClass.rawValue)
        }
    }

    /// Finds the word analysis that contains or overlaps with the given range
    func wordAnalysis(at range: NSRange) -> WordAnalysis? {
        return wordAnalyses.first { analysis in
            NSIntersectionRange(analysis.range, range).length > 0
        }
    }

    /// Finds the word analysis for the exact range
    func wordAnalysis(forExactRange range: NSRange) -> WordAnalysis? {
        return wordAnalyses.first { analysis in
            NSEqualRanges(analysis.range, range)
        }
    }

    /// Finds the word analysis that best matches the given range (largest intersection)
    func wordAnalysis(bestMatchingRange range: NSRange) -> WordAnalysis? {
        var bestMatch: WordAnalysis?
        var largestIntersection = 0

        for analysis in wordAnalyses {
            let intersection = NSIntersectionRange(analysis.range, range)
            if intersection.length > largestIntersection {
                largestIntersection = intersection.length
                bestMatch = analysis
            }
        }

        return bestMatch
    }
}
