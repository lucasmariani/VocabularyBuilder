import Foundation
import UIKit

/// Protocol for text formatting services that can apply styling based on analysis
protocol TextFormattingProviding {
    /// Formats text based on analysis results and configuration
    /// - Parameters:
    ///   - analysisResult: The text analysis result
    ///   - configuration: Formatting configuration
    /// - Returns: NSAttributedString with formatting applied
    func formatText(analysisResult: TextAnalysisResult, configuration: TextFormattingConfiguration) -> NSAttributedString
}

/// Service that formats text based on analysis results
class TextFormattingService: TextFormattingProviding {
    
    // MARK: - Public Methods
    
    func formatText(analysisResult: TextAnalysisResult, configuration: TextFormattingConfiguration) -> NSAttributedString {
        let text = analysisResult.originalText
        
        // Create attributed string with base attributes
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: configuration.baseFont,
            .foregroundColor: configuration.baseTextColor
        ]
        
        let attributedString = NSMutableAttributedString(string: text, attributes: baseAttributes)
        
        // Apply highlighting to words with specified lexical classes
        for analysis in analysisResult.wordAnalyses {
            guard let lexicalClass = analysis.lexicalClass,
                  configuration.highlightedLexicalClasses.contains(lexicalClass) else {
                continue
            }
            
            var highlightAttributes = baseAttributes
            configuration.highlightStyle.apply(to: &highlightAttributes, baseFont: configuration.baseFont)
            
            attributedString.setAttributes(highlightAttributes, range: analysis.range)
        }
        
        return attributedString
    }
}
