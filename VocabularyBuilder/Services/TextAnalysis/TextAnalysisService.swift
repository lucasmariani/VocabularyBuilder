import Foundation
import NaturalLanguage

/// Protocol for text analysis services that can determine lexical classes
protocol TextAnalysisProviding {
    /// Analyzes the given text and returns word-level lexical class information
    /// - Parameter text: The text to analyze
    /// - Returns: TextAnalysisResult containing word analyses
    func analyzeText(_ text: String) -> TextAnalysisResult
}

/// Service that provides text analysis using Apple's Natural Language framework
class TextAnalysisService: TextAnalysisProviding {
    
    // MARK: - Public Methods
    
    func analyzeText(_ text: String) -> TextAnalysisResult {
        guard !text.isEmpty else {
            return TextAnalysisResult(originalText: text, wordAnalyses: [])
        }
        
        // Create tagger with both lexical class and language detection
        let tagger = NLTagger(tagSchemes: [.lexicalClass, .language])
        tagger.string = text
        
        // Detect dominant language for the entire text as fallback
        let dominantLanguage = Language(language: tagger.dominantLanguage)

        var wordAnalyses: [WordAnalysis] = []
        let range = text.startIndex..<text.endIndex
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        
        // Enumerate through words to get both lexical class and language
        tagger.enumerateTags(in: range, unit: .word, scheme: .lexicalClass, options: options) { lexicalTag, tokenRange in
            let word = String(text[tokenRange])
            let lexicalClass = lexicalTag.flatMap { LexicalClass(rawValue: $0.rawValue) }
            
            // Get language for this specific word position
            let wordLanguage = dominantLanguage

            // Convert Range<String.Index> to NSRange for UITextView compatibility
            let nsRange = NSRange(tokenRange, in: text)
            
            let analysis = WordAnalysis(
                word: word,
                range: nsRange,
                lexicalClass: lexicalClass,
                language: wordLanguage
            )
            
            wordAnalyses.append(analysis)
            return true
        }
        
        return TextAnalysisResult(originalText: text, wordAnalyses: wordAnalyses)
    }
}
